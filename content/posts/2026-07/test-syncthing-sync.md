---
title: "Testing Syncthing Sync to GitHub Pages"
date: 2026-07-01T17:10:00+08:00
tags: ["syncthing", "blog", "devops"]
draft: false
summary: "Test post to verify Syncthing vault sync → Hugo → GitHub Pages pipeline."
---

This is a test post to validate the new **Syncthing sync pipeline** for my Hugo blog.

## What Changed

Previously, my blog pipeline used Google Drive + rclone to sync Obsidian notes → Hugo → GitHub Pages. The rclone sync was slow and unreliable.

**New pipeline:**
```
MacBook (Obsidian) → Syncthing (P2P LAN) → Pop-OS (Hugo build + git push) → GitHub Pages
```

## Why Syncthing

- **10-100× faster** than rclone Google Drive sync
- Block-level delta sync — only changed blocks transfer
- No cloud rate limits
- Encrypted end-to-end (TLS 1.3)

## Sync Stats

| Metric | Google Drive (rclone) | Syncthing |
|--------|----------------------|-----------|
| Sync time | Minutes | Seconds |
| Reliability | Rate-limited | Direct P2P |
| Cost | Free tier limits | Free, unlimited |

This post proves the pipeline works. If you see this on https://terrygzhou.github.io/ — it worked!

---
*Generated: 2026-07-01 17:10 AEST*
