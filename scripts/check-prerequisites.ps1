# Reports tool availability without changing the computer.
$checks = @('cmake', 'cl', 'git', 'ninja')
Write-Host "KernelScope X — Build Prerequisite Check" -ForegroundColor Cyan
foreach ($name in $checks) {
    $command = Get-Command $name -ErrorAction SilentlyContinue
    if ($command) { Write-Host "[OK]      $name : $($command.Source)" -ForegroundColor Green }
    else { Write-Host "[MISSING] $name" -ForegroundColor Yellow }
}
Write-Host "Run in Visual Studio Developer PowerShell for 'cl' to appear." 
Write-Host "Qt 6 must be installed separately; see docs/SETUP_WINDOWS.md."
