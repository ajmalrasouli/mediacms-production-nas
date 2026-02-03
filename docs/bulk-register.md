📦 docs/bulk-register.md


# Bulk Media Registration (NAS)

This document describes how to **safely bulk-register existing media files**
stored on a NAS into MediaCMS **without re-uploading or duplicating data**.

This approach is designed for:
- Large existing media libraries
- NAS-backed storage
- Minimal downtime
- Safe, repeatable operations

---

## 🎯 What Bulk Registration Does

Bulk registration:
- Scans an existing directory on NAS
- Creates MediaCMS database entries
- Associates metadata with files
- Skips files already registered

Bulk registration **does NOT**:
- Copy files
- Modify media content
- Delete files
- Re-encode existing media automatically

---

## 🧩 Preconditions

Before running bulk registration, ensure:

- MediaCMS containers are running
- NAS is mounted and accessible inside containers
- Media files already exist on NAS
- Encoding profiles are configured correctly
- Sufficient disk space exists for database growth

---

## 📁 Directory Structure (Example)



/mnt/ar-nas/
├── Movies/
│ ├── Movie1.mp4
│ └── Movie2.mkv
├── TV/
│ └── Show/
│ └── Season 01/
│ └── Episode1.mkv
└── Clips/
└── clip01.mp4


This directory is mounted into the container as:


/home/mediacms.io/mediacms/media_files


---

## 🧪 Step 1 — Dry Run (MANDATORY)

Always start with a **dry run**.

```bash
docker exec -it MediaCMS_WEB \
  python bulk_register_nas.py --dry-run

What to check

Paths are correct

Files are detected

Duplicates are reported as [SKIP]

No unexpected directories are scanned

⚠️ If anything looks wrong, stop here and fix paths.

🟢 Step 2 — Commit Registration

Once the dry run output is verified:

docker exec -it MediaCMS_WEB \
  python bulk_register_nas.py --commit

What happens

New files are registered

Database entries are created

Existing media is skipped

Operation can be interrupted safely

🔁 Resume an Interrupted Run

If the process is interrupted:

docker exec -it MediaCMS_WEB \
  python bulk_register_nas.py --commit --resume


MediaCMS will continue from where it left off.

🎯 Register a Subdirectory Only

Useful for testing or staged imports:

docker exec -it MediaCMS_WEB \
  python bulk_register_nas.py --commit \
  --path nas/Movies

⚙️ Performance Considerations

Bulk registration is I/O-bound

Database writes occur on SSD

No transcoding occurs during registration

Encoding jobs are created only if profiles are enabled

Recommended

Disable unused encoding profiles before running

Monitor system load during large imports

Run during off-peak hours

🛑 Common Pitfalls
❌ Running commit without dry run

May cause unwanted registrations.

❌ NAS permissions issues

Ensure containers can read NAS paths.

❌ Encoding overload

Too many enabled profiles can overwhelm CPU.

❌ Expecting files to be copied

Bulk registration indexes files; it does not move them.

🧪 Verification After Run

After completion:

Check MediaCMS UI media count

Verify random samples play correctly

Confirm no duplicate entries

Monitor worker logs for encoding tasks

Useful commands:

docker logs MediaCMS_WORKER --tail 50
docker stats

🧹 Re-running Bulk Registration

Bulk registration is idempotent.

You can safely re-run:

docker exec -it MediaCMS_WEB \
  python bulk_register_nas.py --commit


Only new files will be registered.

📌 Summary

Bulk registration allows MediaCMS to manage
large existing libraries efficiently and safely.

Key principles:

Always dry-run first

Keep databases on SSD

Use NAS only for media

Control encoding workload

Monitor system health

This workflow enables fast onboarding of large libraries
without compromising system stability.