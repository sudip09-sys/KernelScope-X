#pragma once
#include <QObject>
#include <QHash>
#include <chrono>
#include "core/Snapshot.h"

class WindowsCollector final : public QObject {
    Q_OBJECT
public:
    explicit WindowsCollector(QObject *parent = nullptr);

public slots:
    void collect();

signals:
    void snapshotReady(const SystemSnapshot &snapshot);

private:
    struct CpuTimes {
        quint64 creation = 0;
        quint64 total = 0;
    };
    QHash<quint32, CpuTimes> previousProcessTimes_;
    std::chrono::steady_clock::time_point previousTime_{};
    quint64 previousIdle_ = 0;
    quint64 previousTotal_ = 0;
    bool firstSample_ = true;
};
