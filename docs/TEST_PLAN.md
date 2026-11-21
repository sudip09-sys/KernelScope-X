# KernelScope X — Test Plan

## Automated

From a successful Windows CMake build:

```powershell
ctest --test-dir build -C Debug --output-on-failure
```

`KernelScopeTests` covers FCFS, SJF and RR calculation results for a four-process workload and rejects malformed/invalid schedules. These tests have not yet been run on Windows in this conversation.

## Manual acceptance tests

| ID | Action | Expected result |
|---|---|---|
| LIVE-01 | Launch app and observe 2 samples | CPU/RAM and process count update, no freeze |
| LIVE-02 | Start Notepad | New process appears in snapshot and Events |
| LIVE-03 | Search `notepad` | Process list filters by name |
| LIVE-04 | Sort CPU, memory, name, PID | Appropriate ordering |
| LIVE-05 | Select Notepad | PID, PPID, threads and memory appear |
| LIVE-06 | Inspect protected process | Path/memory shows unavailable when access denied |
| LIVE-07 | Pause, then resume | Snapshot stops/restarts updating |
| LIVE-08 | Export JSON | Local file is written to Documents/KernelScope-X |
| SAFE-01 | Select known harmless test process | Confirmation dialog appears before termination |
| SAFE-02 | Try Windows core process | Action blocked, no crash |
| OS-01 | FCFS with P1(0,8),P2(1,4),P3(2,9),P4(3,5) | Avg WT=8.75, TAT=15.25 |
| OS-02 | SJF with same input | Avg WT=7.75, TAT=14.25 |
| OS-03 | RR q=3, same input | Avg WT=13.50, TAT=20.00 |
| OS-04 | Invalid burst/time | Input validation shows error |

## Report evidence policy

Use only real Windows screenshots and actual build/test output. Capture the toolchain versions, system specs, compile log, window screenshots and results, with clear labels indicating live monitoring versus simulations. Compare live stats with Task Manager using the same approximate sampling window (they may not match exactly).
