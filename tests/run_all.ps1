# Parametric Enclosure Generator v13.1 — Test Suite Launcher (Windows PowerShell)
# Run all tests:  .\tests\run_all.ps1
# Run one suite:  .\tests\run_all.ps1 -Suite smoke
# List suites:    .\tests\run_all.ps1 -List
# Dry run:        .\tests\run_all.ps1 -DryRun

param(
    [string]$Suite = "",
    [switch]$List,
    [switch]$DryRun
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$runner    = Join-Path $scriptDir "test_runner.py"

if (-not (Test-Path $runner)) {
    Write-Host "ERROR: test_runner.py not found at $runner" -ForegroundColor Red
    exit 1
}

# Check Python availability
$pythonCmd = $null
try { $null = Get-Command python -ErrorAction Stop; $pythonCmd = "python" }
catch {
    try { $null = Get-Command python3 -ErrorAction Stop; $pythonCmd = "python3" }
    catch {
        Write-Host "ERROR: Python not found. Install Python 3.8+ and add to PATH." -ForegroundColor Red
        exit 1
    }
}

# Build arguments
$args = @($runner)
if ($List)   { $args += "--list" }
if ($DryRun) { $args += "--dry-run" }
if ($Suite)  { $args += "--suite"; $args += $Suite }

Write-Host "============================================" -ForegroundColor Cyan
Write-Host " Parametric Enclosure Generator — Test Suite" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

& $pythonCmd $args

$exitCode = $LASTEXITCODE
if ($exitCode -eq 0) {
    Write-Host "`nALL TESTS PASSED" -ForegroundColor Green
} else {
    Write-Host "`nSOME TESTS FAILED (exit code: $exitCode)" -ForegroundColor Red
}
exit $exitCode
