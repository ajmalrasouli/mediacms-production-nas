#!/bin/bash
# MediaCMS PostgreSQL Backup Script
# Creates logical backups and stores them on NAS

set -e

BACKUP_ROOT="/mnt/ar-nas/backups/mediacms"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")
BACKUP_FILE="$BACKUP_ROOT/mediacms-db-$TIMESTAMP.sql"

echo "Starting MediaCMS database backup..."

# Ensure backup directory exists
mkdir -p "$BACKUP_ROOT"

# Run backup
docker exec MediaCMS_DB \
  pg_dump -U mediacms mediacms \
  > "$BACKUP_FILE"

echo "Backup completed:"
echo "  $BACKUP_FILE"

# Optional: keep last 14 backups only
find "$BACKUP_ROOT" -type f -mtime +14 -name "*.sql" -delete

echo "Old backups cleaned (older than 14 days)."
