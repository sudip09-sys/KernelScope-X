# KernelScope X — Changelog

## 2026-11-24 — Repository organization

- Replaced the oversized top-level README with a concise, current overview, while preserving the original project vision in `docs/PROJECT_VISION.md`.
- Created a navigable documentation index and a guide explaining the different `main` and `gh-pages` web asset layouts.
- Moved main-branch website styles and JavaScript into `assets/website/`; the existing homepage, browser demo and memory-lab URLs remain unchanged.
- Preserved C++/Qt project sources, tests and native build configuration.

**Scope:** Repository/documentation maintenance and static asset reorganization, not a new native feature release.


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
