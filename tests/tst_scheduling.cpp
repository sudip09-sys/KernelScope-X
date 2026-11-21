#include <QtTest/QtTest>
#include "oslab/SchedulingSimulator.h"

class SchedulingTest final : public QObject {
    Q_OBJECT
private slots:
    void standardWorkload() {
        SchedulingSimulator sim;
        const QString work = "P1,0,8\nP2,1,4\nP3,2,9\nP4,3,5";
        auto fcfs = sim.simulate(work, "FCFS");
        auto sjf = sim.simulate(work, "SJF");
        auto rr = sim.simulate(work, "RR", 3);
        QCOMPARE(fcfs.value("error").toString(), QString());
        QCOMPARE(fcfs.value("avgWaiting").toDouble(), 8.75);
        QCOMPARE(fcfs.value("avgTurnaround").toDouble(), 15.25);
        QCOMPARE(sjf.value("avgWaiting").toDouble(), 7.75);
        QCOMPARE(sjf.value("avgTurnaround").toDouble(), 14.25);
        QCOMPARE(rr.value("avgWaiting").toDouble(), 13.5);
        QCOMPARE(rr.value("avgTurnaround").toDouble(), 20.0);
        QCOMPARE(rr.value("totalBurst").toInt(), 26);
    }
    void idleAndInvalidInput() {
        SchedulingSimulator sim;
        auto valid = sim.simulate("P1,3,2\nP2,6,1", "SJF");
        QCOMPARE(valid.value("error").toString(), QString());
        QCOMPARE(valid.value("totalTime").toInt(), 7);
        QCOMPARE(valid.value("segments").toList().at(0).toMap().value("name").toString(), QString("Idle"));
        QVERIFY(!sim.simulate("P1,0,0", "FCFS").value("error").toString().isEmpty());
        QVERIFY(!sim.simulate("P1,0,5\nP1,1,3", "SJF").value("error").toString().isEmpty());
        QVERIFY(!sim.simulate("P1,0,5", "RR", 0).value("error").toString().isEmpty());
    }
};
QTEST_GUILESS_MAIN(SchedulingTest)
#include "tst_scheduling.moc"
