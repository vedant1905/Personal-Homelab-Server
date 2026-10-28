<#
.SYNOPSIS
    Personal Homelab Server - Service Management Script (PowerShell)
#>

param (
    [Parameter(Position=0, Mandatory=$true)]
    [ValidateSet("start", "stop", "restart", "logs", "ps", "update")]
    [string]$Action,

    [Parameter(Position=1, Mandatory=$false)]
    [string]$Target = "all"
)

$ValidStacks = @("all", "core", "network", "monitoring", "storage", "media")

function Ensure-Network {
    $netExists = docker network ls --filter name=homelab_net -q
    if (-not $netExists) {
        docker network create --subnet=172.28.0.0/16 homelab_net | Out-Null
    }
}

switch ($Action) {
    "start" {
        Ensure-Network
        Write-Host "Starting homelab ($Target)..." -ForegroundColor Green
        if ($Target -eq "all") {
            docker compose up -d
        } elseif (Test-Path "compose/$Target.yml") {
            docker compose -f "compose/$Target.yml" up -d
        } else {
            Write-Host "Invalid stack: $Target. Valid: $($ValidStacks -join ', ')" -ForegroundColor Red
            exit 1
        }
    }
    "stop" {
        Write-Host "Stopping homelab ($Target)..." -ForegroundColor Yellow
        if ($Target -eq "all") {
            docker compose down
        } elseif (Test-Path "compose/$Target.yml") {
            docker compose -f "compose/$Target.yml" down
        } else {
            Write-Host "Invalid stack: $Target. Valid: $($ValidStacks -join ', ')" -ForegroundColor Red
            exit 1
        }
    }
    "restart" {
        Write-Host "Restarting homelab ($Target)..." -ForegroundColor Yellow
        if ($Target -eq "all") {
            docker compose restart
        } elseif (Test-Path "compose/$Target.yml") {
            docker compose -f "compose/$Target.yml" restart
        }
    }
    "logs" {
        if ($Target -eq "all") {
            docker compose logs -f --tail=100
        } else {
            docker compose logs -f --tail=100 $Target
        }
    }
    "ps" {
        docker compose ps
    }
    "update" {
        Write-Host "Pulling latest images and updating containers..." -ForegroundColor Yellow
        docker compose pull
        docker compose up -d --remove-orphans
        docker image prune -f
        Write-Host "Update complete." -ForegroundColor Green
    }
}
