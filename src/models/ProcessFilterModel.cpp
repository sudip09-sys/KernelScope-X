#include "models/ProcessFilterModel.h"
#include "models/ProcessModel.h"

ProcessFilterModel::ProcessFilterModel(QObject *parent) : QSortFilterProxyModel(parent) {
    setDynamicSortFilter(true);
    setSortCaseSensitivity(Qt::CaseInsensitive);
    setSortMode(0);
}
void ProcessFilterModel::setSearch(const QString &value) {
    const QString query = value.trimmed();
    if (search_ == query) return;
    search_ = query;
    invalidateFilter();
    emit searchChanged();
}
void ProcessFilterModel::setSortMode(int value) {
    if (value < 0 || value > 4) return;
    const bool changed = sortMode_ != value;
    sortMode_ = value;
    switch (value) {
    case 0: setSortRole(ProcessModel::CpuRole); sort(0, Qt::DescendingOrder); break;
    case 1: setSortRole(ProcessModel::MemoryMbRole); sort(0, Qt::DescendingOrder); break;
    case 2: setSortRole(ProcessModel::NameRole); sort(0, Qt::AscendingOrder); break;
    case 3: setSortRole(ProcessModel::PidRole); sort(0, Qt::AscendingOrder); break;
    case 4: setSortRole(ProcessModel::TreeOrderRole); sort(0, Qt::AscendingOrder); break;
    }
    if (changed) emit sortModeChanged();
}
bool ProcessFilterModel::filterAcceptsRow(int sourceRow, const QModelIndex &parent) const {
    if (search_.isEmpty()) return true;
    const QModelIndex index = sourceModel()->index(sourceRow, 0, parent);
    const QString name = index.data(ProcessModel::NameRole).toString();
    const QString pid = index.data(ProcessModel::PidRole).toString();
    const QString ppid = index.data(ProcessModel::ParentPidRole).toString();
    return name.contains(search_, Qt::CaseInsensitive) || pid.contains(search_) || ppid.contains(search_);
}
