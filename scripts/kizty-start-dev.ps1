# KIzty Agent local development launcher.
$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$BackendDir = Join-Path $RepoRoot "backend"
$Python = Join-Path $RepoRoot ".venv-backend\Scripts\python.exe"
$BackendLog = Join-Path $RepoRoot "backend-server.log"
$BackendErr = Join-Path $RepoRoot "backend-server.err.log"
$FrontendLog = Join-Path $RepoRoot "dev-server.log"
$FrontendErr = Join-Path $RepoRoot "dev-server.err.log"

function Test-PortListening {
    param([int]$Port)
    $connection = Get-NetTCPConnection -State Listen -LocalPort $Port -ErrorAction SilentlyContinue
    return $null -ne $connection
}

function Test-BackendHealth {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/health" -UseBasicParsing -TimeoutSec 3
        return $response.StatusCode -eq 200
    } catch {
        return $false
    }
}

function Wait-Until {
    param(
        [scriptblock]$Condition,
        [int]$TimeoutSeconds,
        [string]$Name
    )

    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    while ((Get-Date) -lt $deadline) {
        if (& $Condition) {
            return
        }
        Start-Sleep -Seconds 2
    }

    throw "$Name did not become ready in $TimeoutSeconds seconds."
}

if (!(Test-Path $Python)) {
    throw "Backend Python venv not found: $Python"
}

if (!(Test-PortListening 8080)) {
    Write-Host "Starting backend on http://localhost:8080 ..."
    Remove-Item -LiteralPath $BackendLog, $BackendErr -Force -ErrorAction SilentlyContinue

    $env:CORS_ALLOW_ORIGIN = "http://localhost:5173;http://localhost:8080"
    $env:PORT = "8080"
    $env:HOST = "0.0.0.0"
    $env:USER_AGENT = "KIzty-Agent-Dev/0.1"

    Start-Process `
        -FilePath $Python `
        -ArgumentList @("-m", "uvicorn", "open_webui.main:app", "--host", "0.0.0.0", "--port", "8080", "--workers", "1", "--ws", "auto") `
        -WorkingDirectory $BackendDir `
        -RedirectStandardOutput $BackendLog `
        -RedirectStandardError $BackendErr `
        -WindowStyle Hidden

    Wait-Until -Condition { Test-BackendHealth } -TimeoutSeconds 90 -Name "Backend"
} else {
    Write-Host "Backend already listening on http://localhost:8080"
}

if (!(Test-PortListening 5173)) {
    Write-Host "Starting frontend on http://localhost:5173 ..."
    Remove-Item -LiteralPath $FrontendLog, $FrontendErr -Force -ErrorAction SilentlyContinue

    $Npm = (Get-Command npm.cmd -ErrorAction Stop).Source
    Start-Process `
        -FilePath $Npm `
        -ArgumentList @("run", "dev", "--", "--host", "127.0.0.1") `
        -WorkingDirectory $RepoRoot `
        -RedirectStandardOutput $FrontendLog `
        -RedirectStandardError $FrontendErr `
        -WindowStyle Hidden

    Wait-Until -Condition { Test-PortListening 5173 } -TimeoutSeconds 60 -Name "Frontend"
} else {
    Write-Host "Frontend already listening on http://localhost:5173"
}

Write-Host ""
Write-Host "KIzty Agent dev app is ready:"
Write-Host "  http://localhost:5173/"
Write-Host ""
Write-Host "Logs:"
Write-Host "  $BackendLog"
Write-Host "  $BackendErr"
Write-Host "  $FrontendLog"
Write-Host "  $FrontendErr"

Start-Process "http://localhost:5173/"
