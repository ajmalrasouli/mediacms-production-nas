💾 docs/storage-layout.md





This file reinforces your architecture decisions (very valuable).



\# Storage Layout



This document explains how storage is intentionally divided across

different devices to maximise \*\*performance, reliability, and simplicity\*\*.



---



\## 🎯 Storage Design Goals



\- Prevent root filesystem exhaustion

\- Keep databases fast and predictable

\- Store large media files on scalable storage

\- Allow easy recovery and migration

\- Minimise coupling between components



---



\## 🗂️ Storage Overview







Local Host

├── / (Root filesystem)

│ └── OS only

│

├── /mnt/docker (M.2 SSD)

│ ├── Docker runtime

│ ├── PostgreSQL data

│ ├── Redis data

│ └── MediaCMS cache

│

└── /mnt/ar-nas (NAS via NFS)

└── Media files only





---



\## 📍 Component Placement



| Component | Location | Reason |

|--------|---------|-------|

Operating system | Root disk | Stability and simplicity |

Docker runtime | M.2 SSD | Prevent root disk pressure |

PostgreSQL | M.2 SSD | Low latency, data safety |

Redis | M.2 SSD | Fast queue operations |

Transcode cache | M.2 SSD | High I/O workload |

Media files | NAS | Large, persistent storage |



---



\## ❌ What Is Deliberately Avoided



\- Databases on NAS (latency, corruption risk)

\- Docker data on `/`

\- Media files on local disk

\- Mixing cache with media storage



---



\## 🧠 Why This Layout Works



✔ Predictable performance  

✔ Easy to rebuild host  

✔ NAS failure does not corrupt DB  

✔ SSD failure does not destroy media  

✔ Clear ownership of data  



---



\## 🔄 Migration \& Recovery



Because data is separated:

\- Host OS can be rebuilt without media loss

\- Databases can be restored independently

\- Media library does not require re-upload



This layout supports \*\*safe long-term operation\*\*.

