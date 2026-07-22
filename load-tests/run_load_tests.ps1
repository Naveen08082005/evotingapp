# PowerShell Load Test Runner Script for E-Voting System

param (
    [string]$TestName = "all"
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptDir

$K6Exec = ".\k6.exe"
$ResultsDir = ".\results"

if (-not (Test-Path $ResultsDir)) {
    New-Item -ItemType Directory -Force -Path $ResultsDir | Out-Null
}

Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "     E-VOTING SYSTEM k6 LOAD TESTING SUITE          " -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan

function Run-TestScript([string]$ScriptName) {
    Write-Host "`n[RUNNING] Executing load test: $ScriptName.js..." -ForegroundColor Yellow
    
    & $K6Exec run "$ScriptName.js"

    if ($LASTEXITCODE -eq 0) {
        Write-Host "[SUCCESS] $ScriptName completed cleanly!" -ForegroundColor Green
    } else {
        Write-Host "[WARNING] $ScriptName completed with threshold warnings or non-zero exit code ($LASTEXITCODE)." -ForegroundColor Yellow
    }
}

if ($TestName -eq "all" -or $TestName -eq "login") {
    Run-TestScript "login_test"
}

if ($TestName -eq "all" -or $TestName -eq "register") {
    Run-TestScript "register_test"
}

if ($TestName -eq "all" -or $TestName -eq "vote") {
    Run-TestScript "vote_test"
}

if ($TestName -eq "all" -or $TestName -eq "full") {
    Run-TestScript "full_system_test"
}

Write-Host "`n====================================================" -ForegroundColor Cyan
Write-Host "     LOAD TESTING COMPLETED! ALL REPORTS GENERATED.  " -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
