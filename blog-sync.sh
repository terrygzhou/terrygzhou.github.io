#!/bin/bash
# blog-sync.sh — Sync posts from Syncthing vault → Hugo → git push
# Uses local Syncthing-synced vault — no rclone/GDrive dependency

set -euo pipefail

VAULT_LOCAL="$HOME/workspace/Obsidian Vault/Blog/posts"
HUGO_DIR="$HOME/workspace/blog"
HUGO_CONTENT="$HUGO_DIR/content/posts"

echo "📅 $(date '+%Y-%m-%d %H:%M') — Blog sync started"

# Sync vault → Hugo (local rsync, instant, exclude syncthing temps)
mkdir -p "$HUGO_CONTENT"
if ! rsync -a --delete --exclude='.syncthing*' "$VAULT_LOCAL/" "$HUGO_CONTENT/" 2>&1; then
    echo "⚠️ sync failed"
    echo "Status: WARN — sync failed, skipping publish"
    exit 1
fi
echo "✓ Synced: vault → hugo (local rsync)"

# Build Hugo
cd "$HUGO_DIR"
BUILD_OUTPUT=$(hugo --minify 2>&1)
BUILD_LINES=$(echo "$BUILD_OUTPUT" | tail -1)
echo "✓ Hugo build: $BUILD_LINES"

# Git push if changes
git add -A
CHANGES=$(git diff --cached --stat 2>/dev/null || true)
if [ -z "$CHANGES" ]; then
    echo "⚠ No changes to commit"
    echo "Status: OK — no new posts"
    exit 0
fi

git commit -m "blog: update posts"
git push origin main 2>&1
echo "✅ Published! Live at https://terrygzhou.github.io/"
echo "Status: OK — changes published"
