#include "platform/windows/WindowsCollector.h"

#include <algorithm>
#include <chrono>
#include <cmath>
#include <iterator>
#include <windows.h>
#include <tlhelp32.h>
#include <psapi.h>
#include <QDateTime>
#include <QHash>

namespace {
quint64 fileTimeNumber(const FILETIME &ft) {
    ULARGE_INTEGER v;
    v.LowPart = ft.dwLowDateTime;
    v.HighPart = ft.dwHighDateTime;
    return v.QuadPart;
}

class ScopedHandle {
public:
    explicit ScopedHandle(HANDLE h = nullptr) : h_(h) {}
    ~ScopedHandle() { if (h_ && h_ != INVALID_HANDLE_VALUE) CloseHandle(h_); }
    HANDLE get() const { return h_; }
    bool valid() const { return h_ && h_ != INVALID_HANDLE_VALUE; }
    ScopedHandle(const ScopedHandle &) = delete;
    ScopedHandle &operator=(const ScopedHandle &) = delete;
private:
    HANDLE h_;
};
} // namespace

WindowsCollector::WindowsCollector(QObject *parent) : QObject(parent) {}

void WindowsCollector::collect() {
    SystemSnapshot snap;
    snap.sampledAt = QDateTime::currentDateTime();

    MEMORYSTATUSEX memory{};
    memory.dwLength = sizeof(memory);
    if (GlobalMemoryStatusEx(&memory)) {
        snap.memoryTotalBytes = memory.ullTotalPhys;
        snap.memoryUsedBytes = memory.ullTotalPhys - memory.ullAvailPhys;
        snap.memoryPercent = memory.dwMemoryLoad;
    }

    FILETIME idle{}, kernel{}, user{};
    if (GetSystemTimes(&idle, &kernel, &user)) {
        const quint64 idleTime = fileTimeNumber(idle);
        const quint64 totalTime = fileTimeNumber(kernel) + fileTimeNumber(user);
        if (!firstSample_ && totalTime > previousTotal_) {
            const quint64 totalDelta = totalTime - previousTotal_;
            const quint64 idleDelta = idleTime >= previousIdle_ ? idleTime - previousIdle_ : 0;
            snap.cpuPercent = std::clamp(100.0 * double(totalDelta - std::min(idleDelta, totalDelta)) /
                                              double(totalDelta), 0.0, 100.0);
        }
        previousIdle_ = idleTime;
        previousTotal_ = totalTime;
    }

    const auto now = std::chrono::steady_clock::now();
    const double wallNanoseconds = firstSample_ ? 0.0 :
        double(std::chrono::duration_cast<std::chrono::nanoseconds>(now - previousTime_).count());
    const DWORD logicalCpuCount = std::max<DWORD>(1, GetActiveProcessorCount(ALL_PROCESSOR_GROUPS));
    QHash<quint32, CpuTimes> newTimes;

    ScopedHandle snapshot(CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0));
    if (!snapshot.valid()) {
        snap.error = QStringLiteral("Windows denied process enumeration (%1)").arg(GetLastError());
        emit snapshotReady(snap);
        return;
    }

    PROCESSENTRY32W pe{};
    pe.dwSize = sizeof(pe);
    if (Process32FirstW(snapshot.get(), &pe)) {
        do {
            ProcessInfo item;
            item.pid = pe.th32ProcessID;
            item.parentPid = pe.th32ParentProcessID;
            item.name = QString::fromWCharArray(pe.szExeFile);
            item.threads = pe.cntThreads;
            snap.threadCount += pe.cntThreads;

            ScopedHandle h(OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, item.pid));
            if (h.valid()) {
                item.detailsAvailable = true;
                WCHAR exePath[32768]{};
                DWORD pathSize = DWORD(std::size(exePath));
                if (QueryFullProcessImageNameW(h.get(), 0, exePath, &pathSize))
                    item.path = QString::fromWCharArray(exePath, qsizetype(pathSize));

                FILETIME created{}, exited{}, kernelTime{}, userTime{};
                if (GetProcessTimes(h.get(), &created, &exited, &kernelTime, &userTime)) {
                    CpuTimes sample{fileTimeNumber(created),
                                    fileTimeNumber(kernelTime) + fileTimeNumber(userTime)};
                    item.creationTicks = sample.creation;
                    newTimes.insert(item.pid, sample);
                    const auto it = previousProcessTimes_.constFind(item.pid);
                    if (!firstSample_ && wallNanoseconds > 0 && it != previousProcessTimes_.cend() &&
                        it->creation == sample.creation && sample.total >= it->total) {
                        const double cpuNanoseconds = double(sample.total - it->total) * 100.0;
                        item.cpuPercent = std::clamp(
                            100.0 * cpuNanoseconds / (wallNanoseconds * logicalCpuCount), 0.0, 100.0);
                    }
                }
            }

            // Memory queries often require stronger rights than retrieving a PID/path.
            ScopedHandle memHandle(OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ,
                                               FALSE, item.pid));
            if (memHandle.valid()) {
                PROCESS_MEMORY_COUNTERS pmc{};
                pmc.cb = sizeof(pmc);
                if (GetProcessMemoryInfo(memHandle.get(), &pmc, sizeof(pmc))) {
                    item.workingSetBytes = pmc.WorkingSetSize;
                    item.memoryAvailable = true;
                }
            }
            snap.processes.push_back(std::move(item));
        } while (Process32NextW(snapshot.get(), &pe));
    }

    snap.processCount = quint32(snap.processes.size());
    previousProcessTimes_ = std::move(newTimes);
    previousTime_ = now;
    firstSample_ = false;
    emit snapshotReady(snap);
}
