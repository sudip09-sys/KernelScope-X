#pragma once
#include <QObject>
#include <QVariantMap>

class SchedulingSimulator final : public QObject {
    Q_OBJECT
public:
    explicit SchedulingSimulator(QObject *parent = nullptr) : QObject(parent) {}
    Q_INVOKABLE QVariantMap simulate(const QString &csv, const QString &algorithm,
                                     int quantum = 3) const;
};
