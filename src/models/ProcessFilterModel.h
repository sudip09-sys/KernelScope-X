#pragma once
#include <QSortFilterProxyModel>
#include <QString>

class ProcessFilterModel final : public QSortFilterProxyModel {
    Q_OBJECT
    Q_PROPERTY(QString search READ search WRITE setSearch NOTIFY searchChanged)
    Q_PROPERTY(int sortMode READ sortMode WRITE setSortMode NOTIFY sortModeChanged)
public:
    explicit ProcessFilterModel(QObject *parent = nullptr);
    QString search() const { return search_; }
    void setSearch(const QString &value);
    int sortMode() const { return sortMode_; }
    Q_INVOKABLE void setSortMode(int value);
    Q_INVOKABLE int visibleCount() const { return rowCount(); }
signals:
    void searchChanged();
    void sortModeChanged();
protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;
private:
    QString search_;
    int sortMode_ = 0;
};
