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
json="$(docker exec --env-file "$MCOMPOSE_DIR/.env" matomo \
  php -r 'require "/tmp/views_feed.php";')" \
  || { echo "views refresh: PHP generation failed" >&2; exit 1; }
printf '%s' "$json" | python3 -c 'import json,sys; json.load(sys.stdin)' \
  || { echo "views refresh: generated JSON is invalid, aborting" >&2; exit 1; }

# 2. Apply persisted per-key boost offsets (EYW-481) so the boost survives
#    hourly regeneration. Offsets live in views_offsets.json (committed to
#    the repo); missing file or missing key = no offset for that key.
OFFSETS="$BLOG/views_offsets.json"
if [ -f "$OFFSETS" ]; then
  json="$(JSON_IN="$json" OFFSETS_FILE="$OFFSETS" python3 - <<'PYEOF'
import json, os
d = json.loads(os.environ["JSON_IN"])
off = json.load(open(os.environ["OFFSETS_FILE"]))  # flat {path: offset} map
for k, v in d.get("views", {}).items():
    d["views"][k] = v + int(off.get(k, 0))
print(json.dumps(d, indent=4))
PYEOF
  )"
fi

# 3. Write atomically; only commit if content changed.
tmp="$(mktemp "${OUT}.XXXXXX")"
printf '%s\n' "$json" > "$tmp"
if [ -f "$OUT" ] && diff -q "$OUT" "$tmp" >/dev/null; then
  rm -f "$tmp"
  echo "views refresh: $(date -u +'%Y-%m-%dT%H:%M:%SZ') unchanged, no commit"
  exit 0
fi
mv "$tmp" "$OUT"

# 4. Commit + push (git auth via gh credential helper, non-interactive).
ts="$(date -u +'%Y-%m-%d %H:%M:%SZ')"
git add assets/views-data.json
git commit -q -m "blog: update views counter data ($ts)" -- assets/views-data.json
git push -q origin main
echo "views refresh: $(date -u +'%Y-%m-%dT%H:%M:%SZ') committed + pushed"
