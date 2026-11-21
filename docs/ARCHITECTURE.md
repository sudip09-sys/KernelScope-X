# KernelScope X — Phase 1 Architecture

## Layers

- **QML / Qt Quick:** application shell, sidebar, live statistics, process viewer, diagnostic timeline, scheduling lab.
- **C++ models:** `ProcessModel` owns the latest typed snapshot; `ProcessFilterModel` handles search/sort; `MonitorController` publishes metrics, in-memory histories and process events.
- **Dedicated collector thread:** `WindowsCollector` collects real Win32 process and system statistics away from the GUI thread and emits immutable `SystemSnapshot` values through Qt queued signals.
- **Windows APIs:** Tool Help snapshot for process/PPID/thread-count enumeration; process time samples for CPU; `GetSystemTimes` for whole-system CPU; `GlobalMemoryStatusEx` for RAM; permitted `GetProcessMemoryInfo` for working set.
- **Independent simulation engine:** `SchedulingSimulator` calculates FCFS, non-preemptive SJF and RR schedules using user-provided sample workloads. It never changes Windows scheduling.

## Data flow

```text
QTimer (UI thread, 1500 ms)
    -> queued signal to WindowsCollector (dedicated QThread)
    -> Tool Help / Win32 collection
    -> SystemSnapshot (cross-thread value)
    -> MonitorController (UI thread)
    -> ProcessModel, QML properties, events, alerts
    -> live QML window
```

The QML interface never invokes Win32 enumerators. Signal/slot delivery ensures it receives snapshots on the main thread.

## Metrics

- **System CPU (%):** deltas from `GetSystemTimes` for total (kernel+user) and idle, then `(totalDelta-idleDelta)/totalDelta*100`.
- **Per-process CPU (%):** delta in `GetProcessTimes` process CPU time divided by elapsed wall-clock duration and total logical CPU count; 100% means all available logical processors are busy with that one process. The first sample is 0 by design.
- **Memory used:** physical total minus available from `GlobalMemoryStatusEx`, expressed in GiB.
- **Process working set:** resident memory from `GetProcessMemoryInfo` when permissions allow; otherwise `N/A`.
- **Process threads:** `PROCESSENTRY32.cntThreads` from snapshots. Not a per-thread activity view.
- **Events:** inferred by comparing consecutive PID sets. A short-lived process can appear and disappear between samples without being captured, and PID reuse complicates historical relationships.
- **Alerts:** CPU ≥85% or memory ≥90% over at least three samples. These are simple thresholds, not root-cause diagnoses.

## Safety boundaries

The read-only collector runs with the user's normal Windows privileges. Optional process termination requires direct user selection and explicit confirmation, uses Win32 access checks, blocks known critical names and Windows-critical processes, and validates both executable identity and creation timestamp immediately before acting. It does not elevate privileges.

Exported snapshot JSON files are local, in the user's `Documents/KernelScope-X` directory. They may include process names and full executable paths. No automatic network transmission or permanent activity database exists in this milestone.

## Gaps (not yet implemented)

- Full thread inspector with thread IDs and scheduling details
- Per-process TCP/UDP network analysis
- ETW process event stream
- Persistent time-machine SQLite recordings/replay
- Advanced deadlock/race-condition animated modules
- Custom installer and signed release

These belong to later milestones, not to the current runnable foundation.
