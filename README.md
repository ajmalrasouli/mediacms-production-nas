# MediaCMS – Production Docker Deployment (NAS + SSD)

This repository contains a **production-grade MediaCMS deployment** designed for
self-hosting large media libraries using Docker.

## Key Design Goals
- NAS-backed storage for large media files
- SSD-backed databases and caches for performance
- Safe bulk media registration
- Minimal root filesystem usage
- Clear separation of responsibilities

## Architecture Overview
- Media files: NAS (NFS mount)
- PostgreSQL & Redis: local SSD (M.2)
- Docker runtime: local SSD
- Background processing: Celery workers

## Storage Layout
| Component | Location |
|--------|---------|
Media files | NAS |
Postgres data | SSD |
Redis data | SSD |
Docker runtime | SSD |
Transcode cache | SSD |

## Getting Started
```bash
cp .env.example .env
docker compose up -d
