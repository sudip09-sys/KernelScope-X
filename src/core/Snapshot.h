#pragma once

#include <QDateTime>
#include <QMetaType>
#include <QString>
#include <QVector>
#include <QtGlobal>

struct ProcessInfo {
    quint32 pid = 0;
    quint32 parentPid = 0;
    QString name;
    QString path;
    quint32 threads = 0;
    quint64 workingSetBytes = 0;
    quint64 creationTicks = 0; // Windows process creation timestamp, for identity checks
    double cpuPercent = 0.0; // Share of total machine capacity, 0..100
    bool memoryAvailable = false;
    bool detailsAvailable = false;
};

struct SystemSnapshot {
    QDateTime sampledAt;
    double cpuPercent = 0.0;
    double memoryPercent = 0.0;
    quint64 memoryUsedBytes = 0;
    quint64 memoryTotalBytes = 0;
    quint32 processCount = 0;
    quint32 threadCount = 0;
    QVector<ProcessInfo> processes;
    QString error;
};
Q_DECLARE_METATYPE(SystemSnapshot)
