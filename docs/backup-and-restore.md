💾 docs/backup-and-restore.md


# Backup & Restore Strategy

This document describes the **backup and restore strategy** for the MediaCMS
deployment in this repository.

The goal is to enable **fast recovery** from:
- Host failure
- Database corruption
- Accidental deletion
- Migration or rebuild scenarios

The strategy prioritises **simplicity, reliability, and testability**.

---

## 🎯 What Needs to Be Backed Up

| Component | Backup Required | Reason |
|--------|----------------|-------|
PostgreSQL | ✅ Yes | Metadata, users, media index |
Redis | ❌ Optional | Ephemeral queue data |
Media files (NAS) | ❌ Separate | Already stored on NAS |
Docker images | ❌ No | Rebuildable |
Docker runtime | ❌ No | Rebuildable |

---

## 📁 Backup Locations

- **PostgreSQL backups** → NAS
- **Media files** → NAS (managed separately)
- **Configuration** → GitHub repository

---

## 🧠 Backup Philosophy

- Databases are backed up **logically** (not raw volumes)
- Backups are **human-restorable**
- Restores do **not depend on Docker internals**
- Backups are **versioned and timestamped**

---

## 🗄️ PostgreSQL Backup

### Manual Backup

```bash
docker exec MediaCMS_DB \
  pg_dump -U mediacms mediacms \
  > /mnt/ar-nas/backups/mediacms-db-$(date +%F).sql


This produces a portable SQL dump.

Automated Backup Script

Example script:

scripts/db-backup.sh

#!/bin/bash
BACKUP_DIR="/mnt/ar-nas/backups/mediacms"
mkdir -p "$BACKUP_DIR"

docker exec MediaCMS_DB \
  pg_dump -U mediacms mediacms \
  > "$BACKUP_DIR/mediacms-$(date +%F-%H%M).sql"


Make executable:

chmod +x scripts/db-backup.sh

Scheduled Backup (Cron)
crontab -e

0 2 * * * /path/to/mediacms-production-nas/scripts/db-backup.sh


Runs nightly at 02:00.

🔁 Restore Procedure
1️⃣ Prepare clean environment
docker compose down
docker compose up -d db


Wait until PostgreSQL is healthy.

2️⃣ Restore database
cat mediacms-backup.sql | \
docker exec -i MediaCMS_DB psql -U mediacms mediacms

3️⃣ Restart application
docker compose up -d


MediaCMS will reconnect automatically.

🧪 Verification After Restore

Login to MediaCMS UI

Confirm users exist

Confirm media listings appear

Play a sample video

Check logs for errors

🚨 Disaster Recovery Scenarios
Host Rebuild

Reinstall OS

Install Docker

Clone repository

Mount NAS

Restore DB

Start containers

Database Corruption

Stop MediaCMS containers

Restore last known good dump

Restart services

⚠️ What Is NOT Backed Up (By Design)

Redis data (ephemeral)

Docker images

Transcoded files (recreatable)

Temporary cache files

This keeps backups small and reliable.

🛡️ Best Practices

✔ Test restores periodically
✔ Keep multiple backup generations
✔ Store backups outside host filesystem
✔ Document restore steps
✔ Automate where possible

📌 Summary

This backup strategy ensures:

Fast recovery

Minimal complexity

Predictable behaviour

Safe public documentation

It reflects a production-first mindset and avoids fragile backup approaches.