🧱 docs/architecture.md

# MediaCMS – Architecture Overview

This document describes the **system architecture** of the MediaCMS deployment
used in this repository, including service responsibilities, data flow, and
storage decisions.

The goal of this architecture is **reliability, performance, and operational
clarity** rather than maximum feature density.

---

## 🎯 Design Goals

- Support large media libraries stored on NAS
- Keep databases and queues fast and reliable
- Avoid root filesystem exhaustion
- Enable safe bulk media registration
- Keep background processing controlled
- Allow simple recovery and migration

---

## 🧩 High-Level Architecture



┌─────────────────────────┐
│ Client │
│ Browser / API Consumer │
└─────────────┬───────────┘
│ HTTP
▼
┌─────────────────────────┐
│ MediaCMS WEB │
│ Nginx + uWSGI + API │
└─────────────┬───────────┘
│
┌───────┼────────┐
│ │ │
▼ ▼ ▼
┌────────┐ ┌────────┐ ┌────────────┐
│ Redis │ │ Celery │ │ PostgreSQL │
│ Queue │ │ Worker │ │ Database │
└────────┘ └────────┘ └────────────┘
│
▼
┌─────────────────────────┐
│ NAS (NFS Mount) │
│ Media Files Only │
└─────────────────────────┘


---

## 🐳 Container Responsibilities

### MediaCMS WEB
- Serves web UI and API
- Proxies media via Nginx
- Dispatches background jobs
- Does **not** store media locally

### MediaCMS WORKER
- Executes background tasks
- Handles media encoding
- Reads media directly from NAS
- Writes metadata to PostgreSQL

### MediaCMS BEAT
- Schedules periodic tasks
- Maintains background consistency jobs
- Lightweight, time-based execution

### PostgreSQL
- Stores application metadata
- Encoding profiles
- User data
- Media indexes

### Redis
- Message broker for Celery
- Task state and coordination
- Low-latency queue operations

---

## 💾 Storage Architecture



Local Host (Dell OptiPlex)
├── Root Filesystem (/)
│ └── OS only (kept minimal)
│
├── M.2 SSD (/mnt/docker)
│ ├── Docker runtime
│ ├── PostgreSQL data
│ ├── Redis data
│ └── Transcode cache
│
└── NAS (NFS)
└── Media files (videos, images)


### Key Decisions
- Databases are **never** stored on NAS
- Media files are **never** stored on local disk
- Docker runtime is isolated from `/`

---

## 🔄 Data Flow

### Media Playback


Client → MediaCMS WEB → NAS (read-only media)


### Media Upload (if enabled)


Client → MediaCMS WEB → NAS


### Bulk Registration


MediaCMS WEB → NAS scan → PostgreSQL entries


### Encoding Job


WEB → Redis → Worker → NAS (read) → SSD cache → PostgreSQL


---

## 🛡️ Fault Tolerance & Recovery

### NAS Unavailable
- Application remains online
- Media browsing fails gracefully
- No data corruption

### Database Restart
- Containers reconnect automatically
- No manual intervention required

### Worker Failure
- Tasks remain in Redis
- Worker restarts and resumes

---

## 🔐 Security Considerations

- Secrets stored in `.env` only
- `.env` excluded from Git
- No credentials committed
- NAS mounted with least required permissions

---

## 🧪 Observability

- Docker healthchecks for DB and Redis
- `docker stats` for resource monitoring
- Disk usage monitored separately
- Logs rotated via Docker

---

## 📌 Why This Architecture Works Well

✔ Scales media independently of compute  
✔ Keeps DB performance predictable  
✔ Prevents root disk exhaustion  
✔ Simplifies backups and restores  
✔ Easy to migrate or rebuild  

This design intentionally favors **clarity and reliability** over complexity.

---

## 🧠 Future Enhancements

- Prometheus & Grafana monitoring
- Object storage (S3-compatible)
- Read-only media replicas
- Hardware-accelerated encoding

---

## 📄 Summary

This architecture reflects a **production mindset**:
simple, explicit, observable, and safe to operate.

It is suitable for:
- Home servers
- Small teams
- Personal media platforms
- Demonstration of real-world DevOps skills