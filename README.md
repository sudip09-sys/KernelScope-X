# KernelScope X

**A native Windows Task Manager with an Operating Systems learning laboratory.**

Built with **C++20, Qt 6 / QML, CMake and Windows APIs**, KernelScope X makes processes and performance easier to inspect—and OS concepts easier to demonstrate.

[**Project website**](https://sudip09-sys.github.io/KernelScope-X/) · [Interactive web demo](https://sudip09-sys.github.io/KernelScope-X/demo.html) · [Memory Intelligence Lab](https://sudip09-sys.github.io/KernelScope-X/memory-lab.html) · [Windows setup](docs/SETUP_WINDOWS.md)

---

## At a glance

| Experience | What it does | Data |
|---|---|---|
| **Windows desktop app** | CPU/RAM monitoring, process explorer, diagnostics, scheduling laboratory | **Real Windows telemetry** for monitoring; simulated scheduling |
| **Project website** | Presents the system, interactive process map and scheduling preview | Illustrative demo data |
| **Memory Intelligence Lab** | Paging, page tables, TLB cache and First / Best / Worst Fit visualizations | Educational simulation |

**Current code:** v0.2.0 milestone. The earlier native desktop foundation was demonstrated running on Windows; **v0.2.0 still needs a full Windows acceptance test**. The website is not a substitute for the desktop executable.

## Features

- **System Overview:** sampled CPU utilization, physical RAM, running process count and thread count.
- **Process Explorer:** search, sorting, PID/parent PID, executable details, available working-set memory and guarded process termination.
- **Diagnostics:** snapshot-based process events, sustained resource alerts and local JSON export.
- **CPU Scheduling Lab:** FCFS, non-preemptive SJF and Round Robin with Gantt charts and calculated metrics.
- **Memory Lab (browser):** virtual-to-physical address translation, a simplified TLB and contiguous allocation comparisons.

Planned rather than implemented: deeper per-thread and network inspection, persistent performance history, advanced deadlock simulations and a signed installer.

## Screens and demos

| | |
|---|---|
| [Desktop build instructions](docs/SETUP_WINDOWS.md) | Compile and run the real Windows/Qt application |
| [Interactive browser demo](https://sudip09-sys.github.io/KernelScope-X/demo.html) | Try a simulated Process Explorer and scheduling lab |
| [Memory Intelligence Lab](https://sudip09-sys.github.io/KernelScope-X/memory-lab.html) | Experiment with paging, TLB and memory allocation |
| [Memory Lab technical notes](docs/MEMORY_LAB.md) | Lecture values, formulas, expected results and verification checklist |

> **Data integrity:** The GitHub Pages website uses sample values. Only the native application collects real Windows process and system measurements.

## Run the native app

**Requirements:** Windows 11 x64, Visual Studio with the *Desktop development with C++* workload, and a compatible **Qt 6 MSVC kit** with Qt Quick/QML.

**Qt Creator (recommended)**

1. Open `CMakeLists.txt` in Qt Creator.
2. Select your installed **Desktop Qt 6 MSVC 64-bit** kit.
3. Configure, build, and select the `KernelScopeX` target.
4. Run the application.

**Developer PowerShell alternative**

```powershell
.\scripts\build.ps1 -QtPrefix "C:\Qt\<QtVersion>\msvc2022_64" -Configuration Debug -Launch
```

Replace `<QtVersion>` with your installed Qt version. The application targets native Windows, **not WSL**. See [SETUP_WINDOWS.md](docs/SETUP_WINDOWS.md) for prerequisites and troubleshooting.

## Test

From a successfully configured Windows build:

```powershell
ctest --test-dir build -C Debug --output-on-failure
```

See [TEST_PLAN.md](docs/TEST_PLAN.md) for automated and manual acceptance checks. Do not treat source-code checks as proof of a successful new Windows build.

## Repository structure

```text
KernelScope-X/
├── app/                  # Qt application entry and QML screens
├── src/
│   ├── core/             # Monitoring controller and snapshots
│   ├── models/           # Process list and filtering models
│   ├── platform/windows/ # Windows process/resource collector
│   └── oslab/            # CPU scheduling simulator
├── tests/                # Qt-based regression tests
├── scripts/              # Windows build and prerequisite checks
├── docs/                 # Setup, architecture, test plan and report guidance
├── assets/website/       # Web showcase CSS and JavaScript (main branch)
├── index.html            # Public homepage entry point
├── demo.html             # Browser simulation
├── memory-lab.html       # Memory management simulation
├── CMakeLists.txt         # Native app build configuration
├── CHANGELOG.md          # Development history
└── README.md
```

The `gh-pages` branch is deliberately website-only; `main` holds the native application and its documentation. The root HTML entry points remain to preserve existing GitHub Pages URLs.

## Engineering notes

- Collection uses Windows APIs on a background Qt thread; the interface is not supposed to block on process enumeration.
- Some protected process details are unavailable by design. Ending a permitted process requires explicit user confirmation and identity checks.
- The web simulations **do not access, terminate or inspect your computer's processes**.
- JSON snapshots remain local unless you explicitly share them; exported process paths may be sensitive.

## Documentation

[Architecture](docs/ARCHITECTURE.md) · [Windows setup](docs/SETUP_WINDOWS.md) · [Test plan](docs/TEST_PLAN.md) · [Memory Lab](docs/MEMORY_LAB.md) · [Report outline](docs/PROJECT_REPORT_OUTLINE.md) · [Project vision / roadmap](docs/PROJECT_VISION.md) · [Changelog](CHANGELOG.md)

---

**Operating Systems project** · SAH SUDIP · Gachon University · Student ID: 202637610
