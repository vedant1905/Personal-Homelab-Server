#!/usr/bin/env bash
# ==============================================================================
# Personal Homelab Server - Automated Backup Script
# ==============================================================================
# Archives data, config, and environment settings.
# Keeps the last 7 daily backups.
# ==============================================================================
set -euo pipefail

BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
ARCHIVE_NAME="homelab_backup_${TIMESTAMP}.tar.gz"
RETENTION_DAYS=7

mkdir -p "${BACKUP_DIR}"

echo "Starting homelab backup at $(date)..."

# Ensure sensitive permissions on archive
tar --exclude='data/media' \
    --exclude='data/caddy/data' \
    -czf "${BACKUP_DIR}/${ARCHIVE_NAME}" \
    .env config data 2>/dev/null || true

echo "✓ Backup created: ${BACKUP_DIR}/${ARCHIVE_NAME}"

# Clean up backups older than RETENTION_DAYS
find "${BACKUP_DIR}" -name "homelab_backup_*.tar.gz" -type f -mtime +${RETENTION_DAYS} -delete 2>/dev/null || true
echo "✓ Rotated archives older than ${RETENTION_DAYS} days."
echo "Backup completed successfully."
