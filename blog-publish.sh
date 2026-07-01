#!/bin/bash
# blog-publish.sh — Sync posts from Obsidian vault to Hugo, build, and git push
# Run this on Pop-OS to publish blog posts written in Obsidian on MacBook

set -euo pipefail

VAULT_REMOTE="gdrive:workspace/Obsidian Vault/Blog/posts"
HUGO_DIR="$HOME/workspace/blog"
HUGO_CONTENT="$HUGO_DIR/content/posts"

echo "📥 Syncing posts from Obsidian vault → Hugo..."
rclone sync "$VAULT_REMOTE" "$HUGO_CONTENT" --progress 2>&1

echo "🔨 Building Hugo..."
cd "$HUGO_DIR" && hugo --minify

echo "📦 Committing & pushing..."
cd "$HUGO_DIR"
git add -A
CHANGES=$(git diff --cached --stat)
if [ -z "$CHANGES" ]; then
    echo "⚠️  No changes to commit"
    exit 0
fi
git commit -m "blog: update posts"
git push origin main

echo "✅ Published! Live at https://terrygzhou.github.io/"
