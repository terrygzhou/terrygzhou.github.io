#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

BLOG_DIR="$PWD"
POSTS_DIR="$BLOG_DIR/_posts"
LOG_FILE="$BLOG_DIR/refresh.log"

log() {
  local ts
  ts=$(date '+%Y-%m-%d %H:%M:%S')
  echo "[$ts] $*" | tee -a "$LOG_FILE"
}

# ── 1. Count published posts ──────────────────────────────────────────
log "=== Blog refresh started ==="
count=0
for post in "$POSTS_DIR"/*.md; do
  [ -f "$post" ] || continue
  name=$(basename "$post")
  # Only count properly named posts (YYYY-MM-DD-title.md), skip drafts subdir
  if echo "$name" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}-.+\.md$'; then
    count=$((count + 1))
  fi
done
log "Found $count published post(s) in $POSTS_DIR"

# ── 2. Run deploy ─────────────────────────────────────────────────────
log "Running deploy.sh..."
bash "$BLOG_DIR/deploy.sh" 2>&1 | tee -a "$LOG_FILE"
log "=== Refresh complete ==="
