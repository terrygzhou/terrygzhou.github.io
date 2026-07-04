#!/bin/bash
# Sync blog posts from Obsidian Vault to Hugo content
# Usage: ./blog-sync.sh

set -e

VAULT_DIR="$HOME/workspace/Obsidian Vault/Blog/posts"
HUGO_DIR="$PWD/hugo/content/posts"

if [ ! -d "$VAULT_DIR" ]; then
    echo "Error: Obsidian blog directory not found: $VAULT_DIR"
    exit 1
fi

if [ ! -d "$HUGO_DIR" ]; then
    mkdir -p "$HUGO_DIR"
fi

echo "Syncing blog posts from Obsidian to Hugo..."
synced=0

for post in "$VAULT_DIR"/[0-9]*.md; do
    [ -f "$post" ] || continue
    filename=$(basename "$post")
    target="$HUGO_DIR/$filename"
    
    # Copy if doesn't exist or has changed
    if ! [ -f "$target" ] || ! cmp -s "$post" "$target"; then
        cp "$post" "$target"
        echo "  synced: $filename"
        synced=$((synced + 1))
    fi
done

echo "Synced $synced post(s). Ready for Hugo build."