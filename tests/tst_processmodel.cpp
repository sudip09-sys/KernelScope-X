#include <QAbstractItemModelTester>
#include <QSignalSpy>
#include <QtTest>
#include "models/ProcessFilterModel.h"
#include "models/ProcessModel.h"

class ProcessModelTest final : public QObject {
    Q_OBJECT
private slots:
    void preservesRowsAcrossMetricUpdates();
    void rejectsReusedAndUnverifiedIdentity();
    void filtersAndSortsIndependently();
};

void ProcessModelTest::preservesRowsAcrossMetricUpdates() {
    ProcessModel model;
    QAbstractItemModelTester tester(&model, QAbstractItemModelTester::FailureReportingMode::QtTest);
    ProcessInfo selected{.pid = 42, .name = "editor.exe", .creationTicks = 133147923456789011ULL};
    model.setProcesses({selected});
    QPersistentModelIndex persistent = model.index(0, 0);
    QSignalSpy resets(&model, &ProcessModel::modelReset);
    QSignalSpy updates(&model, &ProcessModel::dataChanged);

    selected.cpuPercent = 25;
    model.setProcesses({selected, ProcessInfo{.pid = 12, .name = "shell.exe"}});

    QVERIFY(persistent.isValid());
    QCOMPARE(persistent.row(), 1);
    QCOMPARE(persistent.data(ProcessModel::CpuRole).toDouble(), 25.0);
    QCOMPARE(updates.size(), 1);
    QCOMPARE(resets.size(), 0);
}

void ProcessModelTest::rejectsReusedAndUnverifiedIdentity() {
    ProcessModel model;
    ProcessInfo process{.pid = 42, .name = "editor.exe", .creationTicks = 133147923456789011ULL};
    model.setProcesses({process});
    const QString token = model.details(42).value("identity").toString();
    QCOMPARE(token, QStringLiteral("133147923456789011"));
    QVERIFY(model.matchesIdentity(42, token));
    QPersistentModelIndex original = model.index(0, 0);

    ++process.creationTicks;
    model.setProcesses({process});
    QVERIFY(!original.isValid());
    QVERIFY(!model.matchesIdentity(42, token));
    QVERIFY(model.matchesIdentity(42, QStringLiteral("133147923456789012")));

    process.creationTicks = 0;
    model.setProcesses({process});
    QVERIFY(!model.matchesIdentity(42, {}));
    QVERIFY(!model.matchesIdentity(42, token));
    model.setProcesses({});
    QVERIFY(!model.details(42).value("found").toBool());
}

void ProcessModelTest::filtersAndSortsIndependently() {
    ProcessModel model;
    ProcessFilterModel explorer;
    ProcessFilterModel overview;
    explorer.setSourceModel(&model);
    overview.setSourceModel(&model);
    ProcessInfo first{.pid = 42, .parentPid = 7, .name = "Alpha.exe", .cpuPercent = 2};
    ProcessInfo second{.pid = 8, .parentPid = 1, .name = "beta.exe", .cpuPercent = 8};
    model.setProcesses({first, second});
    QCOMPARE(overview.index(0, 0).data(ProcessModel::PidRole).toUInt(), 8u);

    explorer.setSortMode(2);
    QCOMPARE(explorer.index(0, 0).data(ProcessModel::PidRole).toUInt(), 42u);
    explorer.setSearch(" ALPHA ");
    QCOMPARE(explorer.rowCount(), 1);
    explorer.setSearch("7");
    QCOMPARE(explorer.rowCount(), 1);
    QCOMPARE(explorer.index(0, 0).data(ProcessModel::PidRole).toUInt(), 42u);
    QCOMPARE(overview.rowCount(), 2);

    first.cpuPercent = 12;
    model.setProcesses({first, second});
    QCOMPARE(overview.index(0, 0).data(ProcessModel::PidRole).toUInt(), 42u);
}

QTEST_GUILESS_MAIN(ProcessModelTest)
#include "tst_processmodel.moc"
