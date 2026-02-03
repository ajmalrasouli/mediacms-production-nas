🧪 docs/troubleshooting.md


This shows operational maturity — recruiters love this.

# Troubleshooting Guide

This document lists common operational issues and
their recommended resolutions.

---

## 🟥 MediaCMS Web UI Not Loading

**Symptoms**
- Browser shows connection error
- Container is running but UI unreachable

**Checks**
```bash
docker ps
docker logs MediaCMS_WEB


Common causes

Port already in use

NAS mount unavailable

Database not ready

🟥 Media Not Appearing After Bulk Register

Symptoms

Bulk register completes

Media count unchanged

Checks

docker exec -it MediaCMS_WEB python bulk_register_nas.py --dry-run


Common causes

Incorrect NAS path

Files already registered

Permission issues on NAS

🟥 High CPU Usage

Symptoms

Fans running constantly

Slow UI

Checks

docker stats


Common causes

Too many encoding profiles enabled

Large backlog of encoding jobs

Resolution

Disable unused encoding profiles

Reduce number of workers

🟥 PostgreSQL Container Restarting

Symptoms

MediaCMS fails to start

DB container restarts repeatedly

Checks

docker logs MediaCMS_DB


Common causes

Disk full

Corrupted volume

Incorrect credentials

Resolution

Check disk space

Restore from backup if required

🟥 Redis Warnings About Memory

Symptoms

Redis logs show memory warnings

Resolution

sudo sysctl vm.overcommit_memory=1
echo "vm.overcommit_memory=1" | sudo tee -a /etc/sysctl.conf

🧹 Disk Space Issues

Checks

df -h
docker system df


Resolution

Ensure Docker runs from SSD

Prune unused images

Clean old backups

🟢 General Debug Tips

Always check logs first

Verify mounts before restarting containers

Avoid deleting volumes without backups

Use dry-run before destructive operations

📌 When in Doubt

Stop containers

Check storage mounts

Review logs

Restore from last known good backup