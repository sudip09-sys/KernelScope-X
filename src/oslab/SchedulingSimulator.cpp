#include "oslab/SchedulingSimulator.h"
#include <QList>
#include <QQueue>
#include <QSet>
#include <QStringList>
#include <QVariantList>
#include <QVector>
#include <algorithm>
#include <limits>

namespace {
struct Job {
    QString name;
    int arrival = 0;
    int burst = 0;
    int remaining = 0;
    int firstStart = -1;
    int completion = -1;
    int index = 0;
};

QVariantMap failed(const QString &reason) { return {{"error", reason}}; }
}

QVariantMap SchedulingSimulator::simulate(const QString &csv, const QString &algorithm,
                                           int quantum) const {
    if (algorithm != "FCFS" && algorithm != "SJF" && algorithm != "RR")
        return failed("Choose FCFS, SJF or RR.");
    if (algorithm == "RR" && (quantum < 1 || quantum > 1000))
        return failed("Round Robin quantum must be between 1 and 1000.");

    QVector<Job> jobs;
    QSet<QString> names;
    const QStringList lines = csv.split('\n');
    int sumBurst = 0;
    for (const QString &line : lines) {
        const QString cleaned = line.trimmed();
        if (cleaned.isEmpty() || cleaned.startsWith('#')) continue;
        const QStringList fields = cleaned.split(',');
        if (fields.size() != 3) return failed("Each line must be: ProcessName,Arrival,Burst");
        const QString name = fields[0].trimmed();
        bool arrivedOk = false, burstOk = false;
        const int arrival = fields[1].trimmed().toInt(&arrivedOk);
        const int burst = fields[2].trimmed().toInt(&burstOk);
        if (name.isEmpty() || name.size() > 20 || names.contains(name))
            return failed("Process names must be unique, non-empty and at most 20 characters.");
        if (!arrivedOk || arrival < 0 || arrival > 1000 || !burstOk || burst < 1 || burst > 1000)
            return failed("Arrival must be 0–1000 and burst must be 1–1000.");
        names.insert(name);
        jobs.push_back(Job{name, arrival, burst, burst, -1, -1, int(jobs.size())});
        sumBurst += burst;
        if (jobs.size() > 24) return failed("Use no more than 24 processes.");
    }
    if (jobs.isEmpty()) return failed("Enter at least one process.");

    QVariantList segments;
    auto addSegment = [&](const QString &name, int from, int to) {
        if (to <= from) return;
        segments.append(QVariantMap{{"name", name}, {"start", from}, {"end", to},
                                    {"duration", to - from}, {"idle", name == "Idle"}});
    };

    QVector<int> ordered;
    for (int i = 0; i < jobs.size(); ++i) ordered.append(i);
    std::stable_sort(ordered.begin(), ordered.end(), [&](int a, int b) {
        return jobs[a].arrival < jobs[b].arrival;
    });

    int clock = 0;
    if (algorithm == "FCFS") {
        for (int ix : ordered) {
            Job &p = jobs[ix];
            if (clock < p.arrival) { addSegment("Idle", clock, p.arrival); clock = p.arrival; }
            p.firstStart = clock;
            clock += p.burst;
            p.remaining = 0;
            p.completion = clock;
            addSegment(p.name, p.firstStart, clock);
        }
    } else if (algorithm == "SJF") {
        int finished = 0;
        while (finished < jobs.size()) {
            int chosen = -1;
            for (int i = 0; i < jobs.size(); ++i) {
                const Job &p = jobs[i];
                if (p.remaining == 0 || p.arrival > clock) continue;
                if (chosen == -1 || p.burst < jobs[chosen].burst ||
                    (p.burst == jobs[chosen].burst &&
                     (p.arrival < jobs[chosen].arrival ||
                      (p.arrival == jobs[chosen].arrival && p.index < jobs[chosen].index))))
                    chosen = i;
            }
            if (chosen == -1) {
                int nextArrival = std::numeric_limits<int>::max();
                for (const Job &p : jobs) if (p.remaining > 0) nextArrival = std::min(nextArrival, p.arrival);
                addSegment("Idle", clock, nextArrival);
                clock = nextArrival;
                continue;
            }
            Job &p = jobs[chosen];
            p.firstStart = clock;
            clock += p.burst;
            p.completion = clock;
            p.remaining = 0;
            ++finished;
            addSegment(p.name, p.firstStart, clock);
        }
    } else {
        QQueue<int> ready;
        int nextArrival = 0, finished = 0;
        while (finished < jobs.size()) {
            while (nextArrival < ordered.size() && jobs[ordered[nextArrival]].arrival <= clock)
                ready.enqueue(ordered[nextArrival++]);
            if (ready.isEmpty()) {
                int nextTime = jobs[ordered[nextArrival]].arrival;
                addSegment("Idle", clock, nextTime);
                clock = nextTime;
                continue;
            }
            const int ix = ready.dequeue();
            Job &p = jobs[ix];
            if (p.firstStart == -1) p.firstStart = clock;
            const int begin = clock;
            const int run = std::min(quantum, p.remaining);
            clock += run;
            p.remaining -= run;
            addSegment(p.name, begin, clock);
            while (nextArrival < ordered.size() && jobs[ordered[nextArrival]].arrival <= clock)
                ready.enqueue(ordered[nextArrival++]);
            if (p.remaining > 0) ready.enqueue(ix);
            else { p.completion = clock; ++finished; }
        }
    }

    double totalWaiting = 0, totalTurnaround = 0, totalResponse = 0;
    QVariantList rows;
    for (const Job &p : jobs) {
        const int tat = p.completion - p.arrival;
        const int waiting = tat - p.burst;
        const int response = p.firstStart - p.arrival;
        totalWaiting += waiting;
        totalTurnaround += tat;
        totalResponse += response;
        rows.append(QVariantMap{{"name", p.name}, {"arrival", p.arrival},
                                {"burst", p.burst}, {"start", p.firstStart},
                                {"completion", p.completion}, {"turnaround", tat},
                                {"waiting", waiting}, {"response", response}});
    }
    return {{"error", ""}, {"algorithm", algorithm}, {"quantum", quantum},
            {"segments", segments}, {"rows", rows}, {"totalTime", clock},
            {"totalBurst", sumBurst}, {"avgWaiting", totalWaiting / jobs.size()},
            {"avgTurnaround", totalTurnaround / jobs.size()},
            {"avgResponse", totalResponse / jobs.size()}};
}
