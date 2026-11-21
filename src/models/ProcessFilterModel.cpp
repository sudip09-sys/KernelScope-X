#include "models/ProcessFilterModel.h"
#include "models/ProcessModel.h"

ProcessFilterModel::ProcessFilterModel(QObject *parent) : QSortFilterProxyModel(parent) {
    setDynamicSortFilter(true);
    setSortMode(0);
}
void ProcessFilterModel::setSearch(const QString &value) {
    if (search_ == value) return;
    search_ = value;
    invalidateFilter();
    emit searchChanged();
}
void ProcessFilterModel::setSortMode(int value) {
    if (value < 0 || value > 3) return;
    if (sortMode_ != value) {
        sortMode_ = value;
        emit sortModeChanged();
    }
    switch (value) {
    case 0: setSortRole(ProcessModel::CpuRole); sort(0, Qt::DescendingOrder); break;
    case 1: setSortRole(ProcessModel::MemoryMbRole); sort(0, Qt::DescendingOrder); break;
    case 2: setSortRole(ProcessModel::NameRole); sort(0, Qt::AscendingOrder); break;
    case 3: setSortRole(ProcessModel::PidRole); sort(0, Qt::AscendingOrder); break;
    }
}
bool ProcessFilterModel::filterAcceptsRow(int sourceRow, const QModelIndex &parent) const {
    if (search_.trimmed().isEmpty()) return true;
    const QModelIndex index = sourceModel()->index(sourceRow, 0, parent);
    const QString name = index.data(ProcessModel::NameRole).toString();
    const QString pid = index.data(ProcessModel::PidRole).toString();
    const QString ppid = index.data(ProcessModel::ParentPidRole).toString();
    const QString query = search_.trimmed();
    return name.contains(query, Qt::CaseInsensitive) || pid.contains(query) || ppid.contains(query);
}
