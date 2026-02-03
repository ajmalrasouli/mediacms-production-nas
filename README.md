# MediaCMS – Production-Grade Docker Deployment (NAS + SSD)

This repository demonstrates a **production-ready MediaCMS deployment** designed for hosting large media libraries using Docker, with a strong focus on:

- Correct storage architecture
- Performance and reliability
- Safe migrations and operations
- Clean separation of concerns
- Security best practices

This setup is actively used and battle-tested in a real environment.

---

## 🚀 Key Design Principles

- **Large, immutable data belongs on NAS**
- **Databases and caches belong on fast local SSD**
- **Docker runtime should never fill the root filesystem**
- **Background processing must be controlled and observable**
- **Secrets must never be committed**

---

## 🧱 Architecture Overview

```
+---------------------------+
|     Client Browser        |
+-------------+-------------+
              |
              v
+---------------------------+
|      MediaCMS Web         |
|  (Nginx + uWSGI + API)    |
+-------------+-------------+
              |
      +-------+-------+
      |               |
      v               v
+-----------+   +-------------+
|   Redis   |   | PostgreSQL  |
|  (Queue)  |   |    (DB)     |
+-----------+   +-------------+
      |               |
      +-------+-------+
              |
              v
+---------------------------+
|  Celery Workers / Beat    |
| (Encoding / Background)   |
+-------------+-------------+
              |
              v
+---------------------------+
|    NAS Storage (NFS)      |
|     Media files only      |
+---------------------------+
```

---

## 💾 Storage Layout (Critical Design Choice)

| Component | Location | Reason |
|-----------|----------|--------|
| Media files | NAS (NFS) | Large, persistent, scalable |
| PostgreSQL | Local SSD (M.2) | Low latency, reliability |
| Redis | Local SSD (M.2) | Queue performance |
| Docker runtime | Local SSD (M.2) | Prevent root disk exhaustion |
| Transcode cache | Local SSD (M.2) | High I/O workload |

> **Databases and Docker are intentionally NOT stored on NAS.**

---

## 🐳 Docker Services

| Service | Purpose |
|---------|---------|
| MediaCMS Web | Web UI, API, media serving |
| MediaCMS Worker | Background jobs, encoding |
| MediaCMS Beat | Scheduled tasks |
| PostgreSQL | Application database |
| Redis | Task queue / broker |

All services are orchestrated using **Docker Compose**.

---

## ⚙️ Getting Started

### 1️⃣ Clone repository

```bash
git clone https://github.com/<your-username>/mediacms-production-nas.git
cd mediacms-production-nas
```

### 2️⃣ Configure environment

```bash
cp .env.example .env
```

Edit `.env` and provide your own secrets.

### 3️⃣ Start services

```bash
docker compose up -d
```

### 4️⃣ Access MediaCMS

```
http://<host-ip>:8088
```

---

## 📦 Bulk Media Registration (NAS)

This setup supports bulk registration of existing media without re-uploading or duplicating files.

### Safe workflow

```bash
docker exec -it MediaCMS_WEB python bulk_register_nas.py --dry-run
docker exec -it MediaCMS_WEB python bulk_register_nas.py --commit
```

**Features:**
- ✔ Skips duplicates
- ✔ Does not copy files
- ✔ Can resume if interrupted

See full details in: `docs/bulk-register.md`

---

## 🎛️ Encoding Strategy

- Only required encoding profiles should be enabled
- Unused profiles should be disabled to reduce CPU load
- Encoding workers can be fully disabled if not required

This approach keeps the system responsive even on modest hardware.

---

## 🔐 Security & Secrets

- No secrets are committed
- `.env` is ignored by Git
- `.env.example` documents required variables
- Docker logs are rotated to avoid disk exhaustion

This repository is safe to make public.

---

## 🛠️ Operational Best Practices

- ✔ Monitor disk usage
- ✔ Keep Docker data off `/`
- ✔ Use SSD for DB and cache
- ✔ Test migrations before cleanup
- ✔ Separate media from application state

A full list is available in: `docs/dos-and-donts.md`

---

## 🧪 Health & Observability

Basic health and disk checks are provided via:

```bash
scripts/health-check.sh
```

This can be extended with:
- Prometheus
- Grafana
- Alerting (email / webhook)

---

## 📌 Skills Demonstrated

- Docker & Docker Compose
- Linux storage architecture
- NAS (NFS) integration
- PostgreSQL operations
- Redis task queues
- Media pipelines (FFmpeg)
- Safe data migration
- Secrets management
- Production documentation

---

## ⚠️ Disclaimer

This repository is provided as a reference architecture and showcase. Adapt paths, limits, and resources to match your environment.

---

## 📄 License

MIT

---

## 🔗 Upstream Project

This deployment is based on **MediaCMS**, an open-source media management platform.

- Project website: https://mediacms.io
- Source repository: https://github.com/mediacms-io/mediacms

This repository focuses on **deployment architecture, storage design, and operations**,
and does not modify the upstream MediaCMS source code.

---

## 👤 About the Author

This repository is maintained by an IT / Systems Engineer with hands-on experience in:

- Linux system administration
- Docker & Docker Compose
- Storage architecture (SSD + NAS)
- PostgreSQL & Redis operations
- Media pipelines and background processing
- Safe migrations and backup strategies
- Production documentation and operational runbooks

This project reflects a **real-world deployment mindset**, focusing on reliability,
maintainability, and security rather than minimal examples.

GitHub: https://github.com/ajmalrasouli


