.PHONY: help setup up down restart ps logs update backup clean

help:
	@echo "Personal Homelab Server Commands:"
	@echo "  make setup     - Initialize directories, environment file, and docker network"
	@echo "  make up        - Start all services in the background"
	@echo "  make down      - Stop all services"
	@echo "  make restart   - Restart all services"
	@echo "  make ps        - View status of all running containers"
	@echo "  make logs      - Follow container logs"
	@echo "  make update    - Pull newest container images and restart"
	@echo "  make backup    - Run automated backup script"
	@echo "  make clean     - Remove unused Docker resources"

setup:
	@bash scripts/setup.sh

up:
	docker compose up -d

down:
	docker compose down

restart:
	docker compose restart

ps:
	docker compose ps

logs:
	docker compose logs -f --tail=100

update:
	docker compose pull && docker compose up -d --remove-orphans && docker image prune -f

backup:
	@bash scripts/backup.sh

clean:
	docker system prune -f
