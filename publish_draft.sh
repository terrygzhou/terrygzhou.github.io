#!/usr/bin/env bash
# publish_draft.sh <post-filename> — promote a draft post and its draft assets.
#
# Usage (from the Blog repo root):  ./publish_draft.sh 2026-09-17-plantuml-archimate-agent-diagrams.md
#
# What it does:
#   1. Moves _posts/draft/<post>.md -> _posts/<post>.md
#   2. Moves draft assets: _posts/draft/assets/<slug>/* -> assets/<slug>/
#      (where <slug> = post filename without the .md)
#   3. Rewrites links inside the moved post:
#        [[draft/assets/<slug>/x.png|alt]]   ->  ![alt](/assets/<slug>/x.png)
#        (draft/assets/<slug>/x.puml)        ->  (/assets/<slug>/x.puml)
#   4. Removes the draft: true front-matter flag.
#   5. Removes now-empty draft/assets/<slug>/ and draft/assets/ if empty.
#
# Draft assets live in _posts/draft/assets/ (git-ignored, invisible to the
# live site). On publish they are moved to the published assets/ directory
# and links are rewritten to the published-site /assets/ convention.
set -euo pipefail
cd "$(dirname "$0")"

post="${1:?usage: ./publish_draft.sh <post-filename>}"
slug="${post%.md}"

draft_post="_posts/draft/$post"
final_post="_posts/$post"
draft_assets="_posts/draft/assets/$slug"
final_assets="assets/$slug"

[[ -f "$draft_post" ]] || { echo "error: $draft_post not found" >&2; exit 1; }

# 1. Move the post out of draft/
mv "$draft_post" "$final_post"

# 2. Move draft assets up to the published assets/ dir
if [[ -d "$draft_assets" ]]; then
  mkdir -p "$final_assets"
  mv "$draft_assets"/* "$final_assets"/
  rmdir "$draft_assets"
  rmdir "_posts/draft/assets" 2>/dev/null || true
fi

# 3. Rewrite links: [[draft/assets/<slug>/x.png|alt]] -> ![alt](/assets/<slug>/x.png)
python3 - "$final_post" "$slug" <<'PYEOF'
import re, sys
path, slug = sys.argv[1], sys.argv[2]
src = open(path).read()
# Obsidian wikilink: [[draft/assets/<slug>/file.ext|alt]] -> ![alt](/assets/<slug>/file.ext)
pat = r'!\[\[draft/assets/' + slug + r'/([^\]|]*)\|([^\]]*)\]\]'
rep = r'![\2](/assets/' + slug + r'/\1)'
src = re.sub(pat, rep, src)
# Plain markdown link: (draft/assets/<slug>/file.ext) -> (/assets/<slug>/file.ext)
src = re.sub(r'\(draft/assets/' + slug + '/', '(/assets/' + slug + '/', src)
open(path, 'w').write(src)
PYEOF

# 4. Drop the draft front-matter flag
sed -i '/^draft: true$/d' "$final_post"

echo "published: $final_post"
[[ -d "$final_assets" ]] && echo "assets: $final_assets"
echo "next: ./deploy.sh"
