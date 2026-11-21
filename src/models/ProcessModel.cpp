#include "models/ProcessModel.h"
#include <algorithm>
#include <utility>

ProcessModel::ProcessModel(QObject *parent) : QAbstractListModel(parent) {}
int ProcessModel::rowCount(const QModelIndex &parent) const {
    return parent.isValid() ? 0 : int(processes_.size());
}
QVariant ProcessModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || index.row() < 0 || index.row() >= processes_.size())
        return {};
    const ProcessInfo &p = processes_.at(index.row());
    switch (role) {
    case PidRole: return p.pid;
    case ParentPidRole: return p.parentPid;
    case NameRole: return p.name;
    case CpuRole: return p.cpuPercent;
    case MemoryMbRole: return p.memoryAvailable ? QVariant(double(p.workingSetBytes) / 1048576.0) : QVariant{};
    case ThreadRole: return p.threads;
    case PathRole: return p.path;
    case DetailsAvailableRole: return p.detailsAvailable;
    case MemoryAvailableRole: return p.memoryAvailable;
    case IdentityRole: return identity(p);
    case TreeDepthRole: return treePositions_.value(p.pid).depth;
    case TreeOrderRole: return treePositions_.value(p.pid).order;
    default: return {};
    }
}
QHash<int, QByteArray> ProcessModel::roleNames() const {
    return {
        {PidRole, "pid"}, {ParentPidRole, "parentPid"}, {NameRole, "name"},
        {CpuRole, "cpu"}, {MemoryMbRole, "memoryMb"}, {ThreadRole, "threadCount"},
        {PathRole, "path"}, {DetailsAvailableRole, "detailsAvailable"},
        {MemoryAvailableRole, "memoryAvailable"}, {IdentityRole, "identity"},
        {TreeDepthRole, "treeDepth"}, {TreeOrderRole, "treeOrder"}
    };
}
void ProcessModel::setProcesses(QVector<ProcessInfo> processes) {
    const auto byPid = [](const ProcessInfo &left, const ProcessInfo &right) {
        return left.pid < right.pid;
    };
    std::sort(processes.begin(), processes.end(), byPid);

    QHash<quint32, QList<quint32>> children;
    QList<quint32> roots;
    for (const auto &process : std::as_const(processes)) {
        ProcessInfo parentKey;
        parentKey.pid = process.parentPid;
        const auto parent = std::lower_bound(processes.cbegin(), processes.cend(), parentKey, byPid);

        // Creation times rule out cycles and parent PIDs reused after the child started.
        if (parent != processes.cend() && parent->pid == process.parentPid &&
            parent->creationTicks > 0 && parent->creationTicks < process.creationTicks) {
            children[parent->pid].append(process.pid);
        } else {
            roots.append(process.pid);
        }
    }

    QHash<quint32, TreePosition> nextTree;
    QList<QPair<quint32, int>> pending;
    for (auto root = roots.crbegin(); root != roots.crend(); ++root)
        pending.append({*root, 0});
    while (!pending.isEmpty()) {
        const auto [pid, depth] = pending.takeLast();
        nextTree.insert(pid, {depth, int(nextTree.size())});
        const auto childList = children.constFind(pid);
        if (childList != children.cend()) {
            for (auto child = childList->crbegin(); child != childList->crend(); ++child)
                pending.append({*child, depth + 1});
        }
    }

    // Remove stale rows first. A recycled PID represents a new row.
    for (int row = int(processes_.size()) - 1; row >= 0; --row) {
        const auto &old = processes_.at(row);
        const auto next = std::lower_bound(processes.cbegin(), processes.cend(), old, byPid);
        if (next != processes.cend() && next->pid == old.pid &&
            next->creationTicks == old.creationTicks &&
            next->name.compare(old.name, Qt::CaseInsensitive) == 0)
            continue;
        beginRemoveRows({}, row, row);
        processes_.removeAt(row);
        endRemoveRows();
    }

    for (int row = 0; row < processes.size(); ++row) {
        const auto &next = processes.at(row);
        if (row == processes_.size() || processes_.at(row).pid != next.pid) {
            beginInsertRows({}, row, row);
            processes_.insert(row, next);
            endInsertRows();
            continue;
        }
        const auto &old = processes_.at(row);
        QList<int> roles;
        if (old.name != next.name) roles << NameRole;
        if (old.parentPid != next.parentPid) roles << ParentPidRole;
        if (old.path != next.path) roles << PathRole;
        if (old.threads != next.threads) roles << ThreadRole;
        if (old.cpuPercent != next.cpuPercent) roles << CpuRole;
        if (old.workingSetBytes != next.workingSetBytes ||
            old.memoryAvailable != next.memoryAvailable) roles << MemoryMbRole;
        if (old.memoryAvailable != next.memoryAvailable) roles << MemoryAvailableRole;
        if (old.detailsAvailable != next.detailsAvailable) roles << DetailsAvailableRole;
        processes_[row] = next;
        if (!roles.isEmpty()) emit dataChanged(index(row), index(row), roles);
    }

    if (treePositions_ != nextTree) {
        treePositions_ = std::move(nextTree);
        if (!processes_.isEmpty())
            emit dataChanged(index(0), index(rowCount() - 1), {TreeDepthRole, TreeOrderRole});
    }
}
QVariantMap ProcessModel::details(qint64 pid) const {
    for (const ProcessInfo &p : processes_) {
        if (qint64(p.pid) == pid) {
            return {
                {"found", true}, {"pid", p.pid}, {"parentPid", p.parentPid},
                {"name", p.name}, {"path", p.path.isEmpty() ? "Unavailable (permissions or exited)" : p.path},
                {"threads", p.threads}, {"cpu", p.cpuPercent},
                {"memoryMb", p.memoryAvailable ? QVariant(double(p.workingSetBytes) / 1048576.0) : QVariant{}},
                {"identity", identity(p)},
                {"detailsAvailable", p.detailsAvailable},
                {"memoryAvailable", p.memoryAvailable}
            };
        }
    }
    return {{"found", false}};
}

QString ProcessModel::identity(const ProcessInfo &process) {
    return process.creationTicks ? QString::number(process.creationTicks) : QString{};
}
bool ProcessModel::matchesIdentity(qint64 pid, const QString &token) const {
    return !token.isEmpty() && details(pid).value("identity").toString() == token;
}
