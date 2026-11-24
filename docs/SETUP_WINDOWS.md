# KernelScope X — Windows Build Guide

**Target:** Windows 11 x64. Compile directly in Windows, **not WSL**. The Win32 backend enumerates host Windows processes and cannot run as a Linux binary.

## 1. Install tools

1. Install Microsoft Visual Studio Community with the **Desktop development with C++** workload. Include MSVC compiler, Windows 11 SDK, and CMake tools.
2. Install **Qt 6** with Qt Quick/QML and Qt Quick Controls, selecting a kit built for the **same/compatible MSVC toolchain**. Qt Creator is optional but useful.
3. Use **Developer PowerShell for Visual Studio** to expose `cl` and the Windows SDK in your PATH.
4. Optionally install Git.

**Qt kit compatibility matters:** a MinGW Qt kit is *not* interchangeable with an MSVC build. A kit folder often resembles `C:\Qt\<QtVersion>\msvc2022_64`, but the actual version/path depends on your installation. Do not copy the example version literally unless it exists on your computer.

Official documentation:
- Visual Studio download: https://visualstudio.microsoft.com/downloads/
- Qt download: https://www.qt.io/download-qt-installer-oss
- Qt 6 QML+CMake: https://doc.qt.io/qt-6/cmake-build-qml-application.html

## 2. Prepare the project

Download the [repository ZIP](https://github.com/sudip09-sys/KernelScope-X/archive/refs/heads/main.zip) or clone the repository into a normal Windows folder, such as `C:\Users\<you>\Projects\KernelScope-X`. The ZIP must be extracted before opening `CMakeLists.txt`.

Open **Developer PowerShell for Visual Studio** and navigate to that folder:

```powershell
cd "$HOME\Projects\KernelScope-X"
.\scripts\check-prerequisites.ps1
```

## 3. Build and run

Provide the real Qt installation directory containing `lib\cmake\Qt6\Qt6Config.cmake`:

```powershell
.\scripts\build.ps1 -QtPrefix "C:\Qt\<QtVersion>\msvc2022_64" -Configuration Debug -Launch
```

Alternatively run commands manually:

```powershell
cmake -S . -B build -DCMAKE_PREFIX_PATH="C:\Qt\<QtVersion>\msvc2022_64"
cmake --build build --config Debug --parallel
ctest --test-dir build -C Debug --output-on-failure
.\build\Debug\KernelScopeX.exe
```

Qt Creator can also open `CMakeLists.txt`, detect a suitable Qt/MSVC kit, and run/debug the app directly.

### Packaging the app for another PC

Once the Windows build has been verified, use Qt's `windeployqt` against the **Release** executable to gather Qt DLLs and QML imports. Test the resulting directory on a clean Windows machine before building an installer. `windeployqt` is a Qt command provided by your selected kit; dependencies and paths differ per machine.

## 4. Troubleshooting

| Issue | What to check |
|---|---|
| `cl` not recognized | Start Developer PowerShell, install C++ workload |
| `Qt6Config.cmake` missing | Set `QtPrefix` to matching Qt MSVC kit |
| `Qt6QuickControls2` missing | Install Qt Quick Controls module in Qt Maintenance Tool |
| Compiler/Qt incompatibility | Select Qt kit compatible with your MSVC toolchain |
| QML module fails to load | Verify QML files and use Qt Creator for detailed engine errors |
| Process fields unavailable | Some Windows processes restrict inspection; this is expected |
| CPU shows zero initially | The first reading establishes a baseline; subsequent samples compute deltas |
| Charts do not refresh | Verify app is not paused and target process is still running |

## 5. Safe first-run checklist

- [ ] App launches without administrator rights.
- [ ] CPU/RAM change when Windows workload changes.
- [ ] Process count and visible names correspond approximately to Windows Task Manager.
- [ ] Search by name and PID filters results.
- [ ] Select an ordinary process and inspect its details.
- [ ] Export a local JSON snapshot from Diagnostics.
- [ ] Run a sample FCFS, SJF and RR scheduling simulation.
- [ ] Do **not** terminate unknown/system processes. Test termination only on a disposable program you intentionally launched.

**Current status:** The source project was assembled here, but a native Windows build and runtime smoke test have not yet been performed. Do not submit screenshots or claim tests until you run them on your own Windows machine.
