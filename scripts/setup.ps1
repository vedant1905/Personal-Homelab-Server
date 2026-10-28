<#
.SYNOPSIS
    Personal Homelab Server - Setup Script for Windows / PowerShell
#>

Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "        Personal Homelab Server - Setup (PowerShell) " -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan

# 1. Check prerequisites
Write-Host "`n[1/4] Checking prerequisites..." -ForegroundColor Yellow
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "Error: Docker CLI not found. Make sure Docker Desktop is installed and running." -ForegroundColor Red
    exit 1
}
Write-Host "✓ Docker CLI found." -ForegroundColor Green

# 2. Setup Environment file
Write-Host "`n[2/4] Configuring environment variables..." -ForegroundColor Yellow
if (-not (Test-Path ".env")) {
    if (Test-Path ".env.example") {
        Copy-Item ".env.example" ".env"
        Write-Host "✓ Created .env from .env.example." -ForegroundColor Green
    } else {
        Write-Host "Error: .env.example not found." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✓ .env already exists." -ForegroundColor Green
}

# 3. Create persistent directories
Write-Host "`n[3/4] Creating persistent data directories..." -ForegroundColor Yellow
$dirs = @(
    "data/caddy/data", "data/caddy/config",
    "data/dockge/data",
    "data/adguard/work", "data/adguard/conf",
    "data/uptime-kuma",
    "data/vaultwarden",
    "data/shared_storage",
    "data/filebrowser",
    "data/jellyfin/config", "data/jellyfin/cache",
    "data/media/movies", "data/media/tv", "data/media/downloads",
    "data/qbittorrent/config",
    "backups"
)

foreach ($d in $dirs) {
    if (-not (Test-Path $d)) {
        New-Item -ItemType Directory -Path $d -Force | Out-Null
    }
}

if (-not (Test-Path "data/filebrowser/database.db")) {
    New-Item -ItemType File -Path "data/filebrowser/database.db" -Force | Out-Null
}
Write-Host "✓ Data directories verified." -ForegroundColor Green

# 4. Create shared Docker network
Write-Host "`n[4/4] Initializing Docker network..." -ForegroundColor Yellow
$netExists = docker network ls --filter name=homelab_net -q
if (-not $netExists) {
    docker network create --subnet=172.28.0.0/16 homelab_net | Out-Null
    Write-Host "✓ Created Docker network 'homelab_net'." -ForegroundColor Green
} else {
    Write-Host "✓ Docker network 'homelab_net' already exists." -ForegroundColor Green
}

Write-Host "`n====================================================" -ForegroundColor Green
Write-Host "Setup complete!" -ForegroundColor Green
Write-Host "Run: docker compose up -d" -ForegroundColor Cyan
Write-Host "Or manage via: .\scripts\manage.ps1 start all" -ForegroundColor Cyan
Write-Host "Dashboard: http://localhost:3000" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Green
