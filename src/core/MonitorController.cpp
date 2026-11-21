#include "core/MonitorController.h"
#include "models/ProcessModel.h"
#include "platform/windows/WindowsCollector.h"

#include <QDateTime>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QStandardPaths>
#include <algorithm>
#include <iterator>
#include <windows.h>

MonitorController::MonitorController(ProcessModel *model, QObject *parent)
    : QObject(parent), model_(model) {
    qRegisterMetaType<SystemSnapshot>("SystemSnapshot");
    collector_ = new WindowsCollector();
    collector_->moveToThread(&collectionThread_);
    connect(&collectionThread_, &QThread::finished, collector_, &QObject::deleteLater);
    connect(this, &MonitorController::requestCollection, collector_, &WindowsCollector::collect,
            Qt::QueuedConnection);
    connect(collector_, &WindowsCollector::snapshotReady, this, &MonitorController::onSnapshot,
            Qt::QueuedConnection);
    collectionThread_.start();
    timer_.setInterval(1500);
    connect(&timer_, &QTimer::timeout, this, &MonitorController::refresh);
    timer_.start();
    refresh();
}
MonitorController::~MonitorController() {
    timer_.stop();
    collectionThread_.quit();
    collectionThread_.wait();
}
void MonitorController::setPaused(bool value) {
    if (paused_ == value) return;
    paused_ = value;
    emit pausedChanged();
    if (!paused_) refresh();
}
void MonitorController::refresh() {
    if (pending_ || paused_) return;
    pending_ = true;
    emit requestCollection();
}
void MonitorController::onSnapshot(const SystemSnapshot &snapshot) {
    pending_ = false;
    snapshot_ = snapshot;
    model_->setProcesses(snapshot.processes);
    if (history_.size() == 60) history_.removeFirst();
    history_.append(snapshot.cpuPercent);
    highCpuSamples_ = snapshot.cpuPercent >= 85 ? highCpuSamples_ + 1 : 0;
    highMemorySamples_ = snapshot.memoryPercent >= 90 ? highMemorySamples_ + 1 : 0;
    QStringList newAlerts;
    if (highCpuSamples_ >= 3)
        newAlerts << QStringLiteral("CPU above 85% for at least three consecutive samples.");
    if (highMemorySamples_ >= 3)
        newAlerts << QStringLiteral("Physical memory above 90% for at least three consecutive samples.");
    if (newAlerts.isEmpty()) newAlerts << QStringLiteral("No sustained high-resource alerts. Monitoring continues.");
    if (newAlerts != alerts_) { alerts_ = newAlerts; emit alertsChanged(); }

    QSet<quint32> current;
    for (const auto &p : snapshot.processes) current.insert(p.pid);
    if (hasPriorSnapshot_) {
        const QString stamp = snapshot.sampledAt.toString("hh:mm:ss");
        int added = 0;
        for (const auto &p : snapshot.processes) {
            if (!previousPids_.contains(p.pid) && added++ < 6)
                events_.prepend(QStringLiteral("%1  START  %2 (PID %3)").arg(stamp, p.name).arg(p.pid));
        }
        int removed = 0;
        for (quint32 pid : previousPids_) {
            if (!current.contains(pid) && removed++ < 6)
                events_.prepend(QStringLiteral("%1  EXIT   PID %2").arg(stamp).arg(pid));
        }
        while (events_.size() > 60) events_.removeLast();
        emit eventsChanged();
    }
    previousPids_ = std::move(current);
    hasPriorSnapshot_ = true;
    emit statsChanged();
}
QString MonitorController::exportSnapshot() {
    const QString location = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    if (location.isEmpty()) return QStringLiteral("Documents directory unavailable.");
    QDir folder(location + "/KernelScope-X");
    if (!folder.exists() && !folder.mkpath(".")) return QStringLiteral("Cannot create export directory.");
    const QString filename = folder.filePath("snapshot_" +
        QDateTime::currentDateTime().toString("yyyyMMdd_HHmmss_zzz") + ".json");
    QJsonObject root{{"source", "live Windows API collection"},
                     {"sampledAt", snapshot_.sampledAt.toString(Qt::ISODate)},
                     {"cpuPercent", snapshot_.cpuPercent},
                     {"memoryPercent", snapshot_.memoryPercent},
                     {"memoryUsedBytes", double(snapshot_.memoryUsedBytes)},
                     {"memoryTotalBytes", double(snapshot_.memoryTotalBytes)}};
    QJsonArray list;
    for (const auto &p : snapshot_.processes) {
        list.append(QJsonObject{{"pid", int(p.pid)}, {"ppid", int(p.parentPid)},
            {"name", p.name}, {"path", p.path}, {"cpuPercent", p.cpuPercent},
            {"threads", int(p.threads)},
            {"workingSetBytes", p.memoryAvailable ? QJsonValue(double(p.workingSetBytes)) : QJsonValue()}});
    }
    root.insert("processes", list);
    QFile file(filename);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate))
        return QStringLiteral("Cannot write snapshot file: %1").arg(file.errorString());
    file.write(QJsonDocument(root).toJson(QJsonDocument::Indented));
    file.close();
    return QStringLiteral("Saved: %1").arg(filename);
}
QString MonitorController::terminateSelectedProcess(qint64 pid, const QString &expectedName) {
    if (pid <= 4 || pid > 0xFFFFFFFFLL || pid == qint64(GetCurrentProcessId()))
        return QStringLiteral("Blocked: cannot end this process.");
    const QVariantMap info = model_->details(pid);
    if (!info.value("found").toBool() ||
        info.value("name").toString().compare(expectedName, Qt::CaseInsensitive) != 0)
        return QStringLiteral("Process changed or disappeared; refresh selection.");
    const QString name = expectedName.toLower();
    static const QStringList protectedNames = {
        "system", "registry", "smss.exe", "csrss.exe", "wininit.exe",
        "winlogon.exe", "services.exe", "lsass.exe", "svchost.exe"
    };
    if (protectedNames.contains(name)) return QStringLiteral("Blocked: protected core Windows process.");
    HANDLE h = OpenProcess(PROCESS_TERMINATE | PROCESS_QUERY_LIMITED_INFORMATION, FALSE, DWORD(pid));
    if (!h) return QStringLiteral("Access denied or process no longer exists (error %1).").arg(GetLastError());

    // Do not act if Windows cannot confirm the process is non-critical.
    using CriticalFn = BOOL (WINAPI *)(HANDLE, PBOOL);
    const auto fn = reinterpret_cast<CriticalFn>(GetProcAddress(GetModuleHandleW(L"kernel32.dll"),
                                                              "IsProcessCritical"));
    BOOL critical = FALSE;
    if (!fn || !fn(h, &critical) || critical) {
        CloseHandle(h);
        return QStringLiteral("Blocked: critical-process safety check unavailable or positive.");
    }
    // PID reuse guard: require the creation timestamp from the last snapshot
    // to match the currently opened process (not just an executable name).
    FILETIME created{}, exited{}, kernelTime{}, userTime{};
    const quint64 expectedCreation = info.value("creationTicks").toULongLong();
    if (expectedCreation == 0 ||
        !GetProcessTimes(h, &created, &exited, &kernelTime, &userTime)) {
        CloseHandle(h);
        return QStringLiteral("Blocked: process identity cannot be verified.");
    }
    ULARGE_INTEGER actualCreation{};
    actualCreation.LowPart = created.dwLowDateTime;
    actualCreation.HighPart = created.dwHighDateTime;
    if (actualCreation.QuadPart != expectedCreation) {
        CloseHandle(h);
        return QStringLiteral("Blocked: PID was reused. Refresh selection.");
    }
    // Also compare the current executable name against the UI selection.
    WCHAR fullPath[32768]{};
    DWORD pathSize = DWORD(std::size(fullPath));
    if (!QueryFullProcessImageNameW(h, 0, fullPath, &pathSize) ||
        QFileInfo(QString::fromWCharArray(fullPath, qsizetype(pathSize))).fileName()
            .compare(expectedName, Qt::CaseInsensitive) != 0) {
        CloseHandle(h);
        return QStringLiteral("Blocked: executable identity could not be verified.");
    }
    const BOOL ok = TerminateProcess(h, 1);
    const DWORD error = ok ? 0 : GetLastError();
    CloseHandle(h);
    if (!ok) return QStringLiteral("Termination denied (error %1).").arg(error);
    events_.prepend(QDateTime::currentDateTime().toString("hh:mm:ss") +
                   QStringLiteral("  USER ENDED  %1 (PID %2)").arg(expectedName).arg(pid));
    emit eventsChanged();
    refresh();
    return QStringLiteral("Termination requested for PID %1.").arg(pid);
}
