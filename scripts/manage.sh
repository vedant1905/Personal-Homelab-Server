#!/usr/bin/env bash
# ==============================================================================
# Personal Homelab Server - Service Management Script
# ==============================================================================
set -euo pipefail

# ANSI color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

STACKS=("core" "network" "monitoring" "storage" "media")

usage() {
    echo -e "${BLUE}Usage:${NC} $0 {start|stop|restart|logs|ps|update} [stack_name]"
    echo ""
    echo -e "Available stacks: ${YELLOW}all${NC}, ${YELLOW}${STACKS[*]}${NC}"
    echo ""
    echo "Examples:"
    echo "  $0 start all             # Start all services"
    echo "  $0 start core            # Start core stack (Caddy, Homepage, Dockge)"
    echo "  $0 stop media            # Stop media services"
    echo "  $0 restart monitoring    # Restart monitoring services"
    echo "  $0 logs caddy            # View logs for a container"
    echo "  $0 ps                    # View status of all running containers"
    echo "  $0 update                # Pull latest images and recreate containers"
    exit 1
}

ACTION="${1:-}"
TARGET="${2:-all}"

if [ -z "$ACTION" ]; then
    usage
fi

resolve_compose_args() {
    local target="$1"
    if [ "$target" = "all" ]; then
        echo ""
    elif [ -f "compose/${target}.yml" ]; then
        echo "-f compose/${target}.yml"
    else
        echo -e "${RED}Error: Unknown stack '${target}'. Available: all, ${STACKS[*]}${NC}" >&2
        exit 1
    fi
}

case "$ACTION" in
    start)
        echo -e "${GREEN}Starting homelab (${TARGET})...${NC}"
        COMPOSE_FLAGS=$(resolve_compose_args "$TARGET")
        # Ensure network exists
        docker network inspect homelab_net >/dev/null 2>&1 || docker network create --subnet=172.28.0.0/16 homelab_net
        if [ "$TARGET" = "all" ]; then
            docker compose up -d
        else
            docker compose $COMPOSE_FLAGS up -d
        fi
        echo -e "${GREEN}✓ Started ${TARGET}.${NC}"
        ;;
    stop)
        echo -e "${YELLOW}Stopping homelab (${TARGET})...${NC}"
        COMPOSE_FLAGS=$(resolve_compose_args "$TARGET")
        if [ "$TARGET" = "all" ]; then
            docker compose down
        else
            docker compose $COMPOSE_FLAGS down
        fi
        echo -e "${GREEN}✓ Stopped ${TARGET}.${NC}"
        ;;
    restart)
        echo -e "${YELLOW}Restarting homelab (${TARGET})...${NC}"
        COMPOSE_FLAGS=$(resolve_compose_args "$TARGET")
        if [ "$TARGET" = "all" ]; then
            docker compose restart
        else
            docker compose $COMPOSE_FLAGS restart
        fi
        echo -e "${GREEN}✓ Restarted ${TARGET}.${NC}"
        ;;
    logs)
        SERVICE_NAME="${2:-}"
        if [ -z "$SERVICE_NAME" ]; then
            docker compose logs -f --tail=100
        else
            docker compose logs -f --tail=100 "$SERVICE_NAME"
        fi
        ;;
    ps)
        docker compose ps
        ;;
    update)
        echo -e "${YELLOW}Pulling latest images and updating containers...${NC}"
        docker compose pull
        docker compose up -d --remove-orphans
        docker image prune -f
        echo -e "${GREEN}✓ Update complete.${NC}"
        ;;
    *)
        usage
        ;;
esac
