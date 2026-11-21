#pragma once
#include <QAbstractListModel>
#include <QVariantMap>
#include "core/Snapshot.h"

class ProcessModel final : public QAbstractListModel {
    Q_OBJECT
public:
    enum Role {
        PidRole = Qt::UserRole + 1,
        ParentPidRole, NameRole, CpuRole, MemoryMbRole,
        ThreadRole, PathRole, DetailsAvailableRole, MemoryAvailableRole, IdentityRole, TreeDepthRole, TreeOrderRole
    };
    explicit ProcessModel(QObject *parent = nullptr);
    int rowCount(const QModelIndex &parent = {}) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;
    void setProcesses(QVector<ProcessInfo> processes);
    Q_INVOKABLE QVariantMap details(qint64 pid) const;
    static QString identity(const ProcessInfo &process);
    bool matchesIdentity(qint64 pid, const QString &token) const;
    const QVector<ProcessInfo> &allProcesses() const { return processes_; }
private:
    struct TreePosition {
        int depth = 0;
        int order = 0;
        bool operator==(const TreePosition &) const = default;
    };

    QHash<quint32, TreePosition> treePositions_;
    QVector<ProcessInfo> processes_;
};
