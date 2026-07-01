#!/bin/bash
# blog-sync.sh — Sync posts between Obsidian vault and Hugo content
# Usage: ./blog-sync.sh [push|pull|sync]
#   push — Obsidian → Hugo (before hugo build + git push)
#   pull — Hugo → Obsidian (if you edited directly in Hugo dir)
#   sync — two-way sync

set -euo pipefail

VAULT_DIR="$HOME/GoogleDrive/workspace/Obsidian Vault/Blog/posts"
HUGO_DIR="$HOME/workspace/blog/content/posts"

ACTION="${1:-push}"

mkdir -p "$VAULT_DIR" "$HUGO_DIR"

if [ "$ACTION" = "push" ]; then
    rsync -a --delete "$VAULT_DIR/" "$HUGO_DIR/"
    echo "✓ Pushed: vault → hugo ($VAULT_DIR → $HUGO_DIR)"
elif [ "$ACTION" = "pull" ]; then
    rsync -a "$HUGO_DIR/" "$VAULT_DIR/"
    echo "✓ Pulled: hugo → vault ($HUGO_DIR → $VAULT_DIR)"
else
    rsync -a "$VAULT_DIR/" "$HUGO_DIR/"
    rsync -a "$HUGO_DIR/" "$VAULT_DIR/"
    echo "✓ Synced both ways"
fi
