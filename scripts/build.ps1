# Build on native Windows in a Visual Studio Developer PowerShell terminal.
# Example: .\scripts\build.ps1 -QtPrefix "C:\Qt\6.10.2\msvc2022_64" -Configuration Release
param(
    [Parameter(Mandatory=$true)][string]$QtPrefix,
    [ValidateSet('Debug','Release','RelWithDebInfo')][string]$Configuration = 'Debug',
    [switch]$Launch
)
$ErrorActionPreference = 'Stop'
$project = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
if (-not (Test-Path (Join-Path $QtPrefix 'lib\cmake\Qt6\Qt6Config.cmake'))) {
    throw "Qt 6 was not found at $QtPrefix. Select the actual Qt MSVC kit folder."
}
cmake -S $project -B (Join-Path $project 'build') -DCMAKE_PREFIX_PATH=$QtPrefix
if ($LASTEXITCODE -ne 0) { throw 'CMake configure failed. Check MSVC, Windows SDK and Qt kit.' }
cmake --build (Join-Path $project 'build') --config $Configuration --parallel
if ($LASTEXITCODE -ne 0) { throw 'C++ build failed.' }
ctest --test-dir (Join-Path $project 'build') -C $Configuration --output-on-failure
if ($LASTEXITCODE -ne 0) { throw 'Some tests failed.' }
if ($Launch) {
    $exe = Join-Path $project "build\$Configuration\KernelScopeX.exe"
    if (-not (Test-Path $exe)) { $exe = Join-Path $project 'build\KernelScopeX.exe' }
    if (-not (Test-Path $exe)) { throw 'Cannot locate the built application.' }
    & $exe
}
