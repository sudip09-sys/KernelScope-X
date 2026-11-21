# KernelScope X

**Native System Intelligence & Process Diagnostics**  
**Project type:** Advanced Operating Systems project / Windows-native desktop application  
**Status:** v0.2.0 development branch awaiting Windows acceptance  
**Project owner:** SAH SUDIP  
**Student ID:** 202637610  
**Primary platform:** Windows 11 x64  
**Current stack:** C++20 · Qt 6 / QML · CMake · Windows APIs · Qt Test. **Planned:** SQLite and optional ETW

> **Project promise:** Build a genuine, installed Windows desktop program that collects real operating-system data, explains process behavior, and provides safe diagnostics. It is not a website wrapped as a desktop app, and it must not present simulated numbers as live system metrics.

---

## Current implementation (v0.2.0 development milestone)

This package now includes C++20 source, a Qt Quick/QML desktop interface, Windows telemetry collection on a background QThread, search/sort process models, process inspection, CPU trend graph, local diagnostic event history, a confirmation-gated process-end action, JSON snapshot export, and a **separate** FCFS/SJF/RR scheduling simulator with Qt Test cases.

The native interface uses a shared dark Qt theme and scrollable pages that reflow at narrower window sizes. The process explorer keeps selection tied to a process instance across sorting and refreshes, shows filtered counts, and keeps the Overview CPU ranking independent. See the [Windows setup guide](docs/SETUP_WINDOWS.md) and [test plan](docs/TEST_PLAN.md) for verification.

**Implemented source modules:**
- `app/main.cpp` and `app/qml/` — native window, navigation, Overview, Processes, Diagnostics and OS Laboratory pages
- `src/platform/windows/WindowsCollector.*` — live Windows process and machine metrics
- `src/core/MonitorController.*` — queued background collection, history, alerts, events, export, safe confirmed process control
- `src/models/` — queryable/sortable process list and selected-process metadata
- `src/oslab/` — isolated scheduling algorithms, with [`tests/tst_scheduling.cpp`](tests/tst_scheduling.cpp)

**Remaining later phases:** detailed thread and network inspector, ETW, persistent SQLite time-machine, deadlock/race-condition animations, signed installer, academic report/screenshots. The full roadmap below describes the desired finished system; it is **not** a list of features already available.

**Quick start on Windows:** Install Visual Studio C++ tools and a compatible Qt 6 MSVC kit, then use:

```powershell
.\scripts\build.ps1 -QtPrefix "C:\Qt\<QtVersion>\msvc2022_64" -Configuration Debug -Launch
```

The `QtPrefix` shown is a placeholder; replace it with the actual Qt kit directory. See the setup guide before running.

---

## 1. Executive summary

KernelScope X combines the familiar capabilities of a system Task Manager with a deeper process explorer, resource diagnostics, historical monitoring, and an interactive Operating Systems learning laboratory.

Its two central goals are:

1. **Real-world utility.** Monitor and inspect actual Windows processes, threads, CPU and memory consumption, network endpoints, and system performance in a responsive native interface.
2. **Academic demonstration.** Show how OS concepts studied in class—processes, `fork()`-style parent-child relationships, CPU scheduling, threads, synchronization, deadlocks, and resource management—translate into observable behavior and safe educational simulations.

The intended outcome is a credible software-engineering portfolio project **and** a professor-ready Operating Systems project with authentic testing evidence and a written report.

## 2. Motivation and problem

Standard task managers provide lists and graphs, but often do not explain *why* an application is using resources or how its processes relate to each other. KernelScope X will combine monitoring, inspection, investigation, and OS education in one tool.

**Target audience:** Students learning operating systems, developers debugging slow applications, and power users investigating their own PCs.

**Not the goal:** Competing with privileged system debuggers, bypassing Windows security boundaries, removing malware automatically, or claiming to detect every deadlock or memory leak.

## 3. Product principles

- **Native first:** Actual C++/Qt desktop UI, packaged as a Windows application.
- **Truthful telemetry:** Real readings are sourced from operating-system APIs; graphs and labels include units and sampling intervals.
- **Responsive UI:** Monitoring runs off the main UI thread and updates the interface via safe signals/models.
- **Explainable insights:** Rule-based diagnostics cite the measured signal and threshold; never diagnose from a single spike alone.
- **User control and safety:** Read-only by default. Potentially destructive operations require explicit selection, a warning, and confirmation.
- **Respect permissions:** Some protected or elevated processes cannot be inspected or terminated; the UI must say so rather than failing silently.
- **Distinct simulation mode:** Scheduling, deadlocks, and synchronization demonstrations are labeled **simulations** and never interfere with production system processes.
- **Privacy by default:** Local collection, local storage, opt-in recording, no upload/telemetry by default.
- **Ship in usable milestones:** A dependable, testable Task Manager comes before the most advanced features.

## 4. Interface and visual direction

**Style:** Professional dark-mode system utility with optional light theme; neutral backgrounds, clear status colors, restrained motion, readable typography, and consistently spaced tables and panels.

**Main navigation (planned):**

1. **Overview** — live CPU/RAM summary, process count, top resource consumers, recent alerts.
2. **Processes** — searchable/sortable process table, expandable process tree, context actions.
3. **Performance** — per-CPU and memory trends, historical charts, sampling controls.
4. **Inspector** — selected process details, threads, modules, network endpoints, parent/child relations.
5. **Network** — per-process TCP/UDP endpoint view where Windows grants access.
6. **Diagnostics** — persistent high-usage alerts, event timeline, evidence and explanations.
7. **Time Machine** — optional local recording and replay of observed telemetry.
8. **OS Lab** — CPU scheduling, thread/race-condition and deadlock simulations.
9. **Settings** — theme, sampling interval, thresholds, recording/storage controls, safety settings.

**UX requirements:** keyboard navigation, filtering, search by PID/name, sortable columns, resizable panels, helpful empty/loading/access-denied states, clear timestamps, pause/resume collection, accessible contrast, confirmations for actions, and no visible UI freezing during refresh.

### Example live metrics (values must be read from the computer)

| Indicator | Source/meaning | Treatment |
|---|---|---|
| CPU usage | System CPU time deltas over a sampling window | Live percentage with sample interval |
| Memory usage | Physical memory information from Windows | Used/available in GiB plus percentage |
| Process count | Count of visible processes in the current snapshot | Mark visibility limitations |
| Thread count | Aggregated thread information/snapshot | Distinguish threads from processes |
| Process CPU | Per-process CPU time deltas | Normalize to a documented percentage convention |
| Process memory | Working set/private memory when available | Label the exact metric; never conflate them |
| Network connections | OS endpoint table associated with PID where available | Include state/protocol and privacy controls |

## 5. Feature specification

### 5.1 Live Task Manager — **MVP / required**

- Enumerate running processes with PID, name, parent PID when available, and accessible executable details.
- Display system-wide CPU and memory metrics.
- Display per-process CPU and memory metrics, thread count, and a truthful availability/status field.
- Refresh automatically at configurable intervals without blocking the UI.
- Search, filter, sort, select, inspect, and copy process information.
- Show errors gracefully (process exited; access denied; stale PID; unavailable measurement).
- Optionally request termination of a user-selected permissible process behind a confirmation dialog; disabled for protected/system-sensitive targets and when rights are insufficient.

**MVP acceptance:** Application launches natively; live CPU/RAM and processes update; a user can find and inspect a process; no frozen UI; denied access and exited processes are handled gracefully.

### 5.2 Deep Process Inspector — **Phase 2**

- PID and parent PID, executable path (if permitted), process start time, lifetime, user/account (if available), thread count, priorities when queryable.
- Thread list with IDs and supported details; do not invent Windows scheduling states that the API does not expose.
- Loaded modules and open-handle details only when feasible and authorized; label unsupported access.
- Copy/export snapshot of selected process.

### 5.3 Process DNA / Family Tree — **Phase 2**

- Visual tree derived from observed parent/child identifiers.
- Click nodes to inspect a process and follow known relationships.
- Explain caveats: parents may already have exited and PIDs can be reused; snapshots are not guaranteed to represent a perfectly persistent lineage.
- Related to class exercises using `fork()`, PID, PPID, and `wait()` (the Linux exercises serve as conceptual references, not Windows APIs).

### 5.4 Performance Profiler — **Phase 2–3**

- Rolling CPU and memory charts; selectable window and sampling interval.
- Identify high and persistent resource use; annotate observed spikes.
- Export summary snapshots/CSV.
- Distinguish *sustained memory growth* from proof of a memory leak.

### 5.5 Network Inspector — **Phase 3**

- List TCP/UDP endpoints by PID when supported.
- Present protocol, local/remote endpoints, state where applicable.
- Explain permission and data availability limits; do not claim the endpoint proves malicious activity.

### 5.6 Smart Performance Detective — **Phase 3**

- Rule-based alerts for high CPU duration, high working-set memory, unexpected process count change, and configured thresholds.
- Each alert shows **what was measured, for how long, threshold, and confidence/limitations**.
- User-configurable thresholds, snooze, dismiss, and history.
- No unsupported claim of AI diagnosis; ML is an optional later experiment, not part of the promised MVP.

### 5.7 Time Machine / Event Timeline — **Phase 3–4**

- Opt-in local recording of timestamped snapshots/alerts.
- Timeline scrubbing and replay of **recorded metrics only**.
- Retention and deletion controls; bounded storage use.
- Explicitly **not** Windows System Restore or a replay of actual process execution.
- Optional advanced Windows Event Tracing (ETW) adapter when justified and permissions allow.

### 5.8 Safe Process Control — **Phase 2**

- Confirm before ending a process; identify PID/name and show that unsaved work may be lost.
- Prevent accidental destructive operations on protected/system-sensitive processes; respect OS access control.
- Use least-privilege query handles by default; request additional rights only for an explicitly authorized action.
- Log permitted user actions locally with timestamp and result; no hidden auto-termination.

### 5.9 OS Research Laboratory — **Phase 3–4, simulated**

A separate, clearly labeled educational environment:

- **CPU Scheduling:** FCFS, non-preemptive SJF, SRTF, Round Robin; configurable arrivals/bursts/quantum; Gantt charts; completion/turnaround/waiting/response times; algorithm comparison.
- **Process Lab:** Visual explanation of parent-child process relationships and exit/reaping behavior; Windows live data and Linux teaching examples distinguished.
- **Thread Lab:** Thread count, shared-memory examples, `join`, lock synchronization and controlled race-condition demonstrations.
- **Deadlock Lab:** Resource-allocation graphs; four Coffman conditions; circular wait; lock ordering and timeout/retry simulations; bounded demonstrations only.
- Clearly label values as **sample/simulated** and never mix them into the live Task Manager charts.

## 6. Operating Systems curriculum mapping

| Coursework topic | KernelScope X demonstration |
|---|---|
| OS purpose and resource management | Overview CPU/memory/process metrics |
| Programs, processes, PCB, states | Process inspector and carefully labeled metadata |
| Process creation and termination | Family tree, process lifetime, safe termination |
| PID / PPID / `fork()` / `wait()` | Parent-child conceptual comparison and Linux lab references |
| CPU scheduling | Scheduling simulator and Gantt/metric comparison |
| Threads and synchronization | Thread inspector and synchronization demonstrations |
| Deadlocks | Four conditions, circular-wait visualization, lock ordering, bounded timeout experiments |
| System calls and kernel/user separation | Explanation of Windows API interactions, permissions and safe boundaries |

## 7. Technical stack and development environment

| Layer | Preferred technology | Role |
|---|---|---|
| Language | **C++20** | Native application and OS integration |
| User interface | **Qt 6 / Qt Quick (QML)** | Desktop windows, sidebar, panels, tables, animations |
| Build | **CMake** | Reproducible configuration and builds |
| Windows integration | **Win32 APIs / Windows SDK** | Process, thread, system and networking data |
| Persistence | **SQLite** | Optional recorded sessions, alerts, preferences |
| Testing | **Qt Test** plus focused C++ unit tests | Collectors, calculations, parsers and UI models |
| Profiling | Windows Performance Analyzer / system tools as needed | Benchmarking and validation |
| Packaging | Windows installer strategy selected later | Native executable installation |
| Optional advanced capture | ETW | Event-based diagnostics, later phase |

**Target:** Windows 11 x64; use Microsoft Visual Studio with C++ desktop tooling, Qt 6, and CMake. Development of native Windows process features must run on Windows, **not solely inside WSL**, because WSL observes the Linux environment rather than all host Windows processes.

**Dependencies and setup:** The source repository and build steps will be added **after the first code is implemented and validated**. This planning README deliberately does not claim `cmake` or an installer works yet.

## 8. Architecture

```text
┌──────────────────────────────────────────────────────────┐
│  Qt Quick / QML UI                                       │
│  Overview | Processes | Inspector | Diagnostics | OS Lab │
└─────────────────────────┬────────────────────────────────┘
                          │ Qt signals / models
┌─────────────────────────▼────────────────────────────────┐
│  C++ Application Layer                                   │
│  ProcessModel  MetricsModel  AlertsModel  Settings       │
│  SessionController  ProcessControlService                │
└─────────────────────────┬────────────────────────────────┘
                          │ typed interfaces
┌─────────────────────────▼────────────────────────────────┐
│  Background Collection & Analytics                       │
│  ProcessCollector  CpuSampler  MemorySampler             │
│  ThreadCollector   NetworkCollector  AlertEngine         │
│  SessionRecorder   TimelineReader                        │
└──────────────┬──────────────────────────┬────────────────┘
               │                          │
    ┌──────────▼───────────┐    ┌─────────▼─────────┐
    │ Windows SDK / APIs   │    │ SQLite (opt-in)   │
    │ System information   │    │ Sessions, alerts  │
    │ Process/thread data  │    │ User preferences  │
    └──────────────────────┘    └───────────────────┘

       Separate module: OS Lab simulators (no system changes)
```

### Architectural rules

- OS collectors never directly modify QML widgets; they publish typed snapshots via thread-safe delivery.
- UI updates are throttled or batched; users can pause refresh without stopping the application.
- Access-denied errors, process disappearance, numeric overflow, and PID reuse must be handled.
- Process CPU uses time deltas across samples, not an instantaneous unsupported value.
- Store only opted-in historical data; retain lightweight in-memory rolling buffers for current charts.
- Core calculations, collectors, and simulations should be independently testable.
- Split privileged actions from read-only collectors, with explicit permission checks and confirmation.

### Candidate Windows APIs (subject to spike/verification)

- Process and thread enumeration: Tool Help snapshots (`CreateToolhelp32Snapshot`, `Process32FirstW`, `Process32NextW`, thread APIs), or other documented supported APIs.
- Process CPU timing: `GetProcessTimes`; system CPU: `GetSystemTimes` / documented alternatives.
- Process memory: `GetProcessMemoryInfo`; physical memory: `GlobalMemoryStatusEx`.
- Details/path/priority where permitted: `OpenProcess`, `QueryFullProcessImageNameW`, `GetPriorityClass`, and related documented calls.
- Network endpoints: `GetExtendedTcpTable`, `GetExtendedUdpTable` with limits and permissions acknowledged.
- Thread details: enumerated thread IDs and supported `OpenThread` queries; handle access denial.
- Optional events: Event Tracing for Windows (ETW) in a later phase.

These are architectural candidates, **not claims that code already uses them**.

## 9. Repository layout (planned)

```text
KernelScope-X/
├── README.md
├── LICENSE                    # choose before public release
├── CMakeLists.txt
├── docs/
│   ├── architecture.md
│   ├── requirements.md
│   ├── test-plan.md
│   ├── screenshots/          # real screenshots only
│   └── os-project-report/    # Word report and supporting notes
├── app/
│   ├── main.cpp
│   ├── qml/
│   │   ├── Main.qml
│   │   ├── pages/
│   │   └── components/
│   └── assets/
├── src/
│   ├── platform/windows/
│   ├── collectors/
│   ├── models/
│   ├── diagnostics/
│   ├── recording/
│   ├── process_control/
│   └── os_lab/
├── include/
├── tests/
└── packaging/
```

This is an initial organization proposal; names can change once implementation starts.

## 10. Milestones and realistic scope

### M1 — Working native foundation (must ship first)

- Windows executable opens a Qt/QML window with navigation and responsive layout.
- Live **real** CPU, memory, process count and process list.
- Search, sorting, selected-process detail view and background refresh.
- Robust access-denied and process-exited messages.
- Basic unit/integration tests and real screenshots.

**M1 done when:** a demo can inspect actual running Windows processes without freezing, crashing or fabricating metrics.

### M2 — Process explorer and safe actions

- Family tree/parent-child links with documented caveats.
- Thread inspector, performance charts and snapshot export.
- Confirmed permissible process termination with safeguards and event logging.

### M3 — Distinctive diagnostic features

- Configurable alerts, history recording, process-level investigation timeline.
- Network endpoints view subject to permissions.
- Data-retention settings, session export and validation tests.

### M4 — Operating Systems lab and final polish

- Scheduling Gantt simulator; thread/race-condition demo; bounded deadlock simulator.
- UI polish, accessibility, automated testing, packaging/installer.
- Professor-ready report, authentic screenshots, demo outline and limitations.

**Priority rule:** If deadlines are tight, finish M1 + strong testing + report before adding features from M3/M4. A robust native tool beats an unfinished feature list.

## 11. Functional requirements (initial)

- **FR-01:** List accessible live processes with PID and name.
- **FR-02:** Display system CPU and memory usage with timestamps.
- **FR-03:** Refresh information automatically and allow manual pause/refresh.
- **FR-04:** Search/filter/sort by process fields.
- **FR-05:** Open an inspector for a selected process and display available details.
- **FR-06:** Handle elevated/protected processes and inaccessible fields transparently.
- **FR-07:** Visualize at least one live metric over a recent interval.
- **FR-08:** Record diagnostic history only with user control/consent.
- **FR-09:** Require confirmation and handle errors for any permitted process action.
- **FR-10:** Keep lab simulations logically separate from live system data.

## 12. Non-functional requirements

- Native Windows installation and offline local operation for core functionality.
- Minimal UI stutter while polling; collectors run asynchronously and bound work.
- Read-only and least-privilege default; no silent elevation or remote control.
- Accessible text, keyboard navigation, and explicit error states.
- Defined sampling intervals and units; consistent behavior after system sleep/resume.
- Reasonable data/CPU/memory overhead, to be measured before setting numeric targets.
- Reliable handling of rapidly exiting processes and PID reuse.
- Unit tests for scheduling equations, CPU usage math and alert thresholds.
- Clear privacy policy for local recordings, with delete/export controls.

## 13. Validation and testing plan

| Test | What to verify | Evidence |
|---|---|---|
| Native launch | Clean start, correct window, no web runtime dependency | Real Windows screenshot |
| System stats | CPU/RAM plausibly agree with Windows Task Manager under same sampling basis | Side-by-side capture and method notes |
| Process creation | Launch a test program; observe it appear and then disappear | Timestamped screenshots/log |
| Search and sorting | PID/name search and CPU sort behave correctly | UI capture + unit test |
| Process termination | Only an explicitly selected, safe test process is terminable | Confirmation and result capture |
| Access control | Denied/process-exited states do not crash | Error-state screenshots/log |
| UI responsiveness | Refresh collection does not freeze interaction | Manual test / instrumentation |
| Historical recording | Recording opt-in, pause, export, clear | Saved local sample database |
| Scheduling lab | Compare calculated metrics to hand-verified examples | Tests + Gantt screenshots |
| Deadlock lab | Bounded runs, no terminal/process left stuck | Demonstration and logs |
| Installer | Install, launch and uninstall on target Windows | Installer test record |

**Evidence policy:** Only screenshots, logs, metrics and tests actually executed on the system may appear as real project results. Mockups and sample data must be labeled clearly.

## 14. Security, privacy and limitations

- Some Windows system processes cannot be inspected or ended; never bypass protection mechanisms.
- Stopping a process can cause data loss or instability; all control operations require confirmation and permission checks.
- A process tree based on snapshots may omit historic parents and can be affected by PID reuse.
- “Live process state” is not identical to the textbook five-state scheduling model; only display states supported by the actual data source.
- High CPU, network traffic, or memory growth is not proof of malware or a memory leak.
- Network endpoints may expose sensitive addresses; local-only handling and redacted exports should be considered.
- ETW/advanced system inspection may need special privileges and is not required for the MVP.
- WSL is useful for the class's Linux exercises, but **it does not replace Windows-native development for host process monitoring**.
- A general-purpose OS Task Manager cannot directly replace the Windows scheduler or safely force arbitrary kernel-level changes.

## 15. Professor presentation plan

**Suggested narrative:** “We went beyond a basic process list. KernelScope X is a native system-monitoring application that lets us observe real Windows processes, diagnose resource usage, and connect these observations to the operating-systems concepts we've learned.”

**Proposed demo flow (use only implemented modules):**

1. Open the installed app and show live CPU/RAM monitoring.
2. Launch a harmless test application and find its process by name/PID.
3. Open its inspector, view parent-child details and thread count.
4. Show a short resource trend or configured alert.
5. If implemented, demonstrate safely terminating **only a test process**, with confirmation.
6. Open the OS Lab and explain a scheduling Gantt chart or bounded deadlock example.
7. Close with limitations, tests, and how operating-system APIs power the features.

## 16. Word project report plan

1. Cover page — **SAH SUDIP**, **202637610**, project title and course.
2. Abstract / executive summary.
3. Introduction and problem statement.
4. Objectives and scope.
5. Related OS concepts (processes, scheduling, threads, synchronization, resource management).
6. Requirements and development technologies.
7. System architecture and module design.
8. Implementation details and key documented API usage.
9. Genuine application screenshots and walkthrough.
10. Testing methodology, test cases and actual results.
11. Performance results and limitations.
12. Security/privacy and future improvements.
13. Conclusion and references.
14. Appendix — installation instructions, code excerpts, test logs and repository link.

**Do not report unimplemented features as completed.** Update this report plan as the project grows.

## 17. Success criteria

The final project succeeds when it is **installable, useful and explainable**, not merely visually impressive. It should:

- Run as a real Windows desktop application.
- Show real, clearly labeled resource measurements and an accurate live process list.
- Be safe and responsive under process churn and permission errors.
- Include at least one memorable advanced investigation feature beyond the normal process list.
- Connect demonstrably to Operating Systems theory.
- Have a repeatable test plan, authentic screenshots, and a coherent academic report.

## 18. Current progress and next action

### Current state

- [x] Project concept chosen: **KernelScope X**.
- [x] Native Windows architecture and technology direction selected.
- [x] Feature roadmap, safety constraints and report structure documented.
- [x] Create the repository and CMake/Qt project.
- [ ] Build and run the first native Windows window.
- [x] Implement collectors and process table.
- [ ] Validate displayed readings against Windows system tools.
- [x] Implement process inspection, diagnostics and scheduling simulation.
- [ ] Create authentic demo evidence, installer and final project report.

### Immediate next step

Run the v0.2.0 Windows acceptance checks from the development branch before merging.

---

## 19. Maintaining this README

This file is the project's living source of truth. As development proceeds:

- Update the implemented/remaining checkboxes honestly.
- Record real build/run commands only after testing them.
- Document changes in APIs, feature scope, and architectural decisions.
- Link to verified screenshots, tests, and tagged releases.
- Keep academic report claims synchronized with the app's real behavior.

**Version:** Planning specification v0.1  
**Last updated:** 2026-11-19
