#!/usr/bin/env bash
# refresh_views.sh — publish all-time blog views to the static site.
#
# Query the Matomo DB inside the matomo container -> rewrite
# assets/views-data.json in the blog repo -> git add/commit/push to GitHub
# Pages. Cron runs it hourly; commits only happen when the JSON changes,
# so an hour of silence = no commit.
#
# DB credentials live in matomo-src/.env (host-side, 0600). They are passed
# to the container via `--env-file` so no secret is ever written into the
# public blog repo.
set -euo pipefail

BLOG=/home/terry/projects/terrygzhou.github.io
MCOMPOSE_DIR=/home/terry/projects/matomo-src
OUT="$BLOG/assets/views-data.json"

cd "$BLOG"

# 1. Generate the JSON (PHP runs inside the matomo container, PHP 8.2).
docker cp "$BLOG/views_feed.php" matomo:/tmp/views_feed.php
# Copy views_offsets.json (one-time Umami backfill, EYW-523) into the
# container so __DIR__-relative path in views_feed.php resolves to /tmp.
if [ -f "$BLOG/views_offsets.json" ]; then
  docker cp "$BLOG/views_offsets.json" matomo:/tmp/views_offsets.json
fi
json="$(docker exec --env-file "$MCOMPOSE_DIR/.env" matomo \
  php -r 'chdir("/tmp"); require "/tmp/views_feed.php";')" \
  || { echo "views refresh: PHP generation failed" >&2; exit 1; }
printf '%s' "$json" | python3 -c 'import json,sys; json.load(sys.stdin)' \
  || { echo "views refresh: generated JSON is invalid, aborting" >&2; exit 1; }

# 2. (Removed: the counter is now the real combined site1+site2 pageview total
#    — no artificial boosts, so both sites show the same true number.)
#    The one-time Umami backfill is applied by views_feed.php itself via
#    views_offsets.json (EYW-523); no shell-side step needed.

# 3. Sync the local branch with the remote (a manual run may leave the tree
#    behind origin/main). This script is the ONLY thing that writes
#    assets/views-data.json, so main can only ever be fast-forwarded here —
#    use --ff-only instead of rebase, which needs a fully-clean tree and
#    aborts the whole refresh if any unrelated working-tree file is dirty
#    (the historical bug that froze the counter on 2026-10-20). The
#    cron-appended log files are now untracked (see .gitignore) so the tree
#    stays clean; ff-only still never tries to build a commit on top of dirt.
git fetch -q origin main
if [ "$(git rev-list --count origin/main..HEAD)" -eq 0 ]; then
  # local is at or behind remote: just fast-forward (no-op if already current).
  git merge --ff-only -q origin/main || {
    echo "views refresh: fast-forward failed, aborting" >&2; git status --porcelain >&2; exit 1;
  }
fi

# 4. Write atomically; only commit if content actually changed vs the remote
#    (compare the generated JSON to what's currently published on origin/main,
#    not just the local working copy — so a stale local tree doesn't trigger a
#    spurious commit).
tmp="$(mktemp "${OUT}.XXXXXX")"
printf '%s\n' "$json" > "$tmp"
remote="$(git show origin/main:assets/views-data.json 2>/dev/null || true)"
if [ "$remote" = "$(cat "$tmp")" ]; then
  rm -f "$tmp"
  echo "views refresh: $(date -u +'%Y-%m-%dT%H:%M:%SZ') unchanged on remote, no commit"
  exit 0
fi
mv "$tmp" "$OUT"

# 5. Commit + push (git auth via gh credential helper, non-interactive).
ts="$(date -u +'%Y-%m-%d %H:%M:%SZ')"
git add assets/views-data.json
git commit -q -m "blog: update views counter data ($ts)" -- assets/views-data.json
# Self-heal a lost race: if someone else pushed between our fetch and push,
# rebase and retry once.
if ! git push -q origin main; then
  git rebase -q origin/main
  git push -q origin main
fi
echo "views refresh: $(date -u +'%Y-%m-%dT%H:%M:%SZ') committed + pushed"
