#!/usr/bin/env bash
# ==============================================================================
# Personal Homelab Server - Bootstrap & Setup Script
# ==============================================================================
set -euo pipefail

# ANSI color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}        Personal Homelab Server - Setup             ${NC}"
echo -e "${BLUE}====================================================${NC}"

# 1. Check prerequisites
echo -e "\n${YELLOW}[1/5] Checking prerequisites...${NC}"
if ! command -v docker >/dev/null 2>&1; then
    echo -e "${RED}Error: Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi

if ! docker compose version >/dev/null 2>&1; then
    echo -e "${RED}Error: Docker Compose (v2) is not installed.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker and Docker Compose found.${NC}"

# 2. Setup Environment file
echo -e "\n${YELLOW}[2/5] Configuring environment variables...${NC}"
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo -e "${GREEN}✓ Created .env from .env.example. Please review and customize it if needed.${NC}"
    else
        echo -e "${RED}Error: .env.example not found.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ .env already exists.${NC}"
fi

# 3. Create persistent directories
echo -e "\n${YELLOW}[3/5] Creating persistent data directories...${NC}"
mkdir -p data/caddy/data data/caddy/config
mkdir -p data/dockge/data
mkdir -p data/adguard/work data/adguard/conf
mkdir -p data/uptime-kuma
mkdir -p data/vaultwarden
mkdir -p data/shared_storage
mkdir -p data/filebrowser
mkdir -p data/jellyfin/config data/jellyfin/cache
mkdir -p data/media/movies data/media/tv data/media/downloads
mkdir -p data/qbittorrent/config
mkdir -p backups

# FileBrowser requires an empty database file before volume mount
if [ ! -f "data/filebrowser/database.db" ]; then
    touch data/filebrowser/database.db
fi
echo -e "${GREEN}✓ Data directories verified.${NC}"

# 4. Create shared Docker network
echo -e "\n${YELLOW}[4/5] Initializing Docker network...${NC}"
if ! docker network inspect homelab_net >/dev/null 2>&1; then
    docker network create --subnet=172.28.0.0/16 homelab_net
    echo -e "${GREEN}✓ Created Docker bridge network 'homelab_net'${NC}"
else
    echo -e "${GREEN}✓ Docker bridge network 'homelab_net' already exists.${NC}"
fi

# 5. Set proper permissions
echo -e "\n${YELLOW}[5/5] Setting folder permissions...${NC}"
CURRENT_UID=$(id -u 2>/dev/null || echo 1000)
CURRENT_GID=$(id -g 2>/dev/null || echo 1000)
chmod -R u+rwX data/ backups/ || true
echo -e "${GREEN}✓ Permissions configured for UID ${CURRENT_UID}:${CURRENT_GID}.${NC}"

echo -e "\n${GREEN}====================================================${NC}"
echo -e "${GREEN}Setup complete! Next steps:${NC}"
echo -e "1. Edit ${BLUE}.env${NC} to configure your domain and tokens if needed."
echo -e "2. Run ${BLUE}./scripts/manage.sh start all${NC} or ${BLUE}docker compose up -d${NC}"
echo -e "3. Open Homepage dashboard at ${BLUE}http://localhost:3000${NC} (or your server IP)"
echo -e "${GREEN}====================================================${NC}"
