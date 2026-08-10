#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

BLOG_DIR="$PWD"
POSTS_DIR="$BLOG_DIR/_posts"
DRAFT_DIR="$POSTS_DIR/draft"
LOG_FILE="$BLOG_DIR/refresh.log"

log() {
  local ts
  ts=$(date '+%Y-%m-%d %H:%M:%S')
  echo "[$ts] $*" | tee -a "$LOG_FILE"
}

# ── 1. Scan drafts for ready-to-publish posts ──────────────────────────
log "=== Blog refresh started ==="
log "Scanning $DRAFT_DIR for ready drafts..."

moved=0
if [ -d "$DRAFT_DIR" ]; then
  for draft in "$DRAFT_DIR"/*.md; do
    [ -f "$draft" ] || continue

    name=$(basename "$draft")

    # Must match Jekyll filename convention: YYYY-MM-DD-title.md
    if ! echo "$name" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}-.+\.md$'; then
      log "SKIP $name (does not match date-filename convention)"
      continue
    fi

    # Must have valid YAML frontmatter with layout, title, date
    frontmatter=$(head -30 "$draft")
    has_layout=$(echo "$frontmatter" | grep -c '^layout: ' || true)
    has_title=$(echo "$frontmatter" | grep -c '^title: ' || true)
    has_date=$(echo "$frontmatter" | grep -c '^date: ' || true)
    has_separator=$(echo "$frontmatter" | grep -c '^---$' || true)

    if [ "$has_separator" -ge 2 ] && [ "$has_layout" -ge 1 ] && [ "$has_title" -ge 1 ] && [ "$has_date" -ge 1 ]; then
      # Check minimum content length (at least 200 chars of body after frontmatter)
      body=$(sed '/^---$/,/^---$/d' "$draft" | wc -c)
      if [ "$body" -lt 200 ]; then
        log "SKIP $name (body too short: ${body} chars)"
        continue
      fi

      # Check it doesn't contain obvious WIP markers
      if grep -qiE '^\s*(TODO|FIXME|WIP|DRAFT|XXX|STUB)' "$draft" 2>/dev/null; then
        log "SKIP $name (contains WIP/TODO markers)"
        continue
      fi

      # Strip invisible characters (NBSP, ZWS, BOM, Unicode control chars)
      if perl -pi -e 's/[\x{00a0}\x{200b}\x{202b}\x{202c}\x{202d}\x{202e}\x{2060}\x{feff}]/ /g' "$draft" 2>/dev/null; then
        log "CLEAN invisible chars in $name"
      fi

      # Move to published
      mv "$draft" "$POSTS_DIR/$name"
      log "MOVE $name → published"
      moved=$((moved + 1))
    else
      log "SKIP $name (incomplete frontmatter: layout=$has_layout title=$has_title date=$has_date)"
    fi
  done
else
  log "No draft directory found"
fi

log "Promoted $moved draft(s) to published"

# ── 2. Run deploy ─────────────────────────────────────────────────────
if [ "$moved" -gt 0 ]; then
  log "Running deploy.sh..."
  bash "$BLOG_DIR/deploy.sh" 2>&1 | tee -a "$LOG_FILE"
  log "=== Refresh complete ==="
else
  log "No new drafts to publish — skipping deploy"
  log "=== Refresh complete ==="
fi
