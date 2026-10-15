#!/usr/bin/env bash
# refresh_umami_views.sh — publish all-time Umami blog views to the static site.
#
# Umami twin of refresh_views.sh. Query the Umami Postgres DB (umami-db-1) via
# umami_views_feed.py -> rewrite assets/umami-views-data.json in the blog repo
# -> git add/commit/push to GitHub Pages. Cron runs it hourly; commits happen
# only when the JSON changes, so an hour of silence = no commit.
#
# Same self-heal discipline as refresh_views.sh:
#   * fetch + rebase origin/main first (a manual run can leave the tree behind)
#   * compare against origin/main, NOT the local working copy
#   * rebase + retry once if a concurrent push wins the race
set -euo pipefail

BLOG=/home/terry/projects/terrygzhou.github.io
OUT="$BLOG/assets/umami-views-data.json"

cd "$BLOG"

# 1. Generate the JSON (host Docker path; no secret committed).
json="$(python3 umami_views_feed.py)" || { echo "umami views refresh: generation failed" >&2; exit 1; }
# 2. Validate it parses; abort on bad JSON so we never publish garbage.
printf '%s' "$json" | python3 -c 'import json,sys; json.load(sys.stdin)' \
  || { echo "umami views refresh: generated JSON is invalid, aborting" >&2; exit 1; }

# 3. Self-heal the git tree (rebase only touches this repo's own commits).
git fetch -q origin main
git rebase -q origin/main || { echo "umami views refresh: rebase failed, aborting" >&2; exit 1; }

# 4. Write atomically; commit only if content changed vs origin/main.
tmp="$(mktemp "${OUT}.XXXXXX")"
printf '%s\n' "$json" > "$tmp"
remote="$(git show origin/main:assets/umami-views-data.json 2>/dev/null || true)"
if [ "$remote" = "$(cat "$tmp")" ]; then
  rm -f "$tmp"
  echo "umami views refresh: $(date -u +'%Y-%m-%dT%H:%M:%SZ') unchanged on remote, no commit"
  exit 0
fi
mv "$tmp" "$OUT"

# 5. Commit + push (race-recovery via rebase + retry).
ts="$(date -u +'%Y-%m-%d %H:%M:%SZ')"
git add assets/umami-views-data.json
git commit -q -m "blog: update Umami views counter data ($ts)" -- assets/umami-views-data.json
if ! git push -q origin main; then
  git rebase -q origin/main
  git push -q origin main
fi
echo "umami views refresh: $(date -u +'%Y-%m-%dT%H:%M:%SZ') committed + pushed"
