#include "models/ProcessModel.h"
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
    default: return {};
    }
}
QHash<int, QByteArray> ProcessModel::roleNames() const {
    return {
        {PidRole, "pid"}, {ParentPidRole, "parentPid"}, {NameRole, "name"},
        {CpuRole, "cpu"}, {MemoryMbRole, "memoryMb"}, {ThreadRole, "threadCount"},
        {PathRole, "path"}, {DetailsAvailableRole, "detailsAvailable"},
        {MemoryAvailableRole, "memoryAvailable"}
    };
}
void ProcessModel::setProcesses(QVector<ProcessInfo> processes) {
    beginResetModel();
    processes_ = std::move(processes);
    endResetModel();
}
QVariantMap ProcessModel::details(qint64 pid) const {
    for (const ProcessInfo &p : processes_) {
        if (qint64(p.pid) == pid) {
            return {
                {"found", true}, {"pid", p.pid}, {"parentPid", p.parentPid},
                {"name", p.name}, {"path", p.path.isEmpty() ? "Unavailable (permissions or exited)" : p.path},
                {"threads", p.threads}, {"cpu", p.cpuPercent},
                {"memoryMb", p.memoryAvailable ? QVariant(double(p.workingSetBytes) / 1048576.0) : QVariant{}},
                {"creationTicks", QVariant::fromValue(p.creationTicks)},
                {"detailsAvailable", p.detailsAvailable},
                {"memoryAvailable", p.memoryAvailable}
            };
        }
    }
    return {{"found", false}};
}
