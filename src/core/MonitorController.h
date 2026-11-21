#pragma once
#include <QObject>
#include <QThread>
#include <QTimer>
#include <QVariantList>
#include <QStringList>
#include <QSet>
#include "core/Snapshot.h"

class WindowsCollector;
class ProcessModel;

class MonitorController final : public QObject {
    Q_OBJECT
    Q_PROPERTY(double cpu READ cpu NOTIFY statsChanged)
    Q_PROPERTY(double memory READ memory NOTIFY statsChanged)
    Q_PROPERTY(double usedGiB READ usedGiB NOTIFY statsChanged)
    Q_PROPERTY(double totalGiB READ totalGiB NOTIFY statsChanged)
    Q_PROPERTY(int processes READ processes NOTIFY statsChanged)
    Q_PROPERTY(int threads READ threads NOTIFY statsChanged)
    Q_PROPERTY(QString updated READ updated NOTIFY statsChanged)
    Q_PROPERTY(QVariantList cpuHistory READ cpuHistory NOTIFY statsChanged)
    Q_PROPERTY(QVariantList memoryHistory READ memoryHistory NOTIFY statsChanged)
    Q_PROPERTY(QStringList alerts READ alerts NOTIFY alertsChanged)
    Q_PROPERTY(QStringList events READ events NOTIFY eventsChanged)
    Q_PROPERTY(bool paused READ paused WRITE setPaused NOTIFY pausedChanged)
    Q_PROPERTY(QString error READ error NOTIFY statsChanged)
public:
    explicit MonitorController(ProcessModel *model, QObject *parent = nullptr);
    ~MonitorController() override;

    double cpu() const { return snapshot_.cpuPercent; }
    double memory() const { return snapshot_.memoryPercent; }
    double usedGiB() const { return double(snapshot_.memoryUsedBytes) / 1073741824.0; }
    double totalGiB() const { return double(snapshot_.memoryTotalBytes) / 1073741824.0; }
    int processes() const { return int(snapshot_.processCount); }
    int threads() const { return int(snapshot_.threadCount); }
    QString updated() const { return snapshot_.sampledAt.toString("hh:mm:ss"); }
    QVariantList cpuHistory() const { return cpuHistory_; }
    QVariantList memoryHistory() const { return memoryHistory_; }
    QStringList alerts() const { return alerts_; }
    QStringList events() const { return events_; }
    bool paused() const { return paused_; }
    QString error() const { return snapshot_.error; }
    void setPaused(bool value);
    Q_INVOKABLE void refresh();
    Q_INVOKABLE void refreshOnce();
    Q_INVOKABLE QString exportSnapshot();
    Q_INVOKABLE bool canTerminate(qint64 pid, const QString &name, const QString &identity) const;
    Q_INVOKABLE QString terminateSelectedProcess(qint64 pid, const QString &expectedName,
                                                 const QString &expectedIdentity);
signals:
    void statsChanged();
    void alertsChanged();
    void eventsChanged();
    void pausedChanged();
    void requestCollection();
private slots:
    void onSnapshot(const SystemSnapshot &snapshot);
private:
    ProcessModel *model_;
    SystemSnapshot snapshot_;
    QThread collectionThread_;
    WindowsCollector *collector_ = nullptr;
    QTimer timer_;
    bool pending_ = false;
    bool paused_ = false;
    int highCpuSamples_ = 0;
    int highMemorySamples_ = 0;
    QVariantList cpuHistory_;
    QVariantList memoryHistory_;
    QStringList alerts_;
    QStringList events_;
    QSet<quint32> previousPids_;
    bool hasPriorSnapshot_ = false;
};
