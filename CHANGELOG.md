# KernelScope X — Changelog

## 0.2.0 — Desktop and process explorer

- Compact dark Windows interface with a resource selector, CPU and memory sparklines, and a shared history graph.
- Dense process table with a parent/child view for relationships verified by creation time.
- Scheduling lab with an editable workload, CSV input, and a zoomable execution timeline.
- Clearable process search, filtered counts, distinct row focus and selection, and an independent Overview CPU ranking.
- Incremental process-model updates preserve existing rows across samples. A reused PID invalidates the old selection.
- End-process confirmation captures the PID, executable name and exact creation timestamp. Windows rechecks the same process handle before acting.
- Refresh takes one sample when paused. Added regression coverage for process identities, row updates, filtering and sorting.

## 0.1.0 — Source foundation

- Native Windows C++20 + Qt 6 / QML build configuration.
- Main window with sidebar and four functional pages.
- Background Win32 process, CPU, memory and thread-count sampling.
- Searchable and sortable process list; selected-process inspector.
- Process termination with explicit confirmation and critical/identity safeguards.
- CPU history visualization, diagnostic threshold alerts, snapshot-based process event history.
- Local JSON snapshot export.
- Simulated FCFS, non-preemptive SJF, Round Robin scheduling with input validation.
- Scheduling unit tests and Windows toolchain/build instructions.

**Verification:** Source files assembled and statically checked; Windows compilation and runtime validation still pending.
