#!/bin/bash
# deploy-blog.sh — Build Hugo and deploy directly to gh-pages branch from Pop-OS
set -euo pipefail

BLOG_DIR="$HOME/workspace/blog"
DEPLOY_DIR="/tmp/gh-pages-deploy"

cd "$BLOG_DIR"
echo "🔨 Building Hugo..."
hugo --minify 2>&1 | tail -1

echo "📦 Deploying to gh-pages..."
rm -rf "$DEPLOY_DIR"
mkdir -p "$DEPLOY_DIR"
cp -r public/* "$DEPLOY_DIR/"

cd "$DEPLOY_DIR"
git init
git add -A
git -c user.name="Terry Zhou" -c user.email="terrygzhou@gmail.com" commit -m "deploy: $(date -u '+%Y-%m-%d %H:%M UTC')"

git remote remove origin 2>/dev/null || true
git remote add origin https://github.com/terrygzhou/terrygzhou.github.io.git

# Use gh CLI for auth (already authenticated)
gh auth setup-git 2>/dev/null

echo "🚀 Pushing to gh-pages..."
git push --force origin HEAD:gh-pages

echo "✅ Deployed! Live at https://terrygzhou.github.io/"
