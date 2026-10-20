#!/usr/bin/env python3
# umami_views_feed.py — Umami twin of views_feed.php.
#
# Generates the combined all-time blog pageview JSON for the blog, but reads the
# Umami Postgres DB (container `umami-db-1`) instead of Matomo MariaDB, and
# writes to stdout so refresh_umami_views.sh can capture it into
# assets/umami-views-data.json. Same output contract as views_feed.php:
#   { "site": "terrygzhou.github.io", "generated_at": "...",
#     "views": { "<slug>": <combined-pageview count> } }
# so the Jekyll frontend can flip its fetch from views-data.json to
# umami-views-data.json 1:1.
#
# Counts = raw Umami pageviews (website_event.event_type = 1) summed across the
# two blog domains, keyed by post slug. No offsets/boosts — the number is the
# real combined Umami pageview total (matches the eywalink-side
# sync-umami-pageviews.mjs definition so the two frontends show one number).
#
# DB access is via the host Docker daemon: `docker exec umami-db-1 psql
# -U umami -d umami -t -A -F <tab>`. No secret is committed.

import json
import re
DATE_PREFIX = re.compile(r"^\d{4}(-\d{2}-\d{2})?$")  # legacy "YYYY" or cutover "YYYY-MM-DD"
import subprocess
import sys
from datetime import datetime, timezone

# Umami blog-site universe (mirrors the Matomo idsite=1+2 hardcoding).
SITES = {
    "6d58c865-22aa-4d13-b167-03cdf61b98b8": "eywalink.org",
    "a0b6f621-98c9-4adb-82f9-4f179a08d674": "terrygzhou.github.io",
}


def url_to_slug(url_path):
    """Reduce a tracked url_path to its post slug (None if not a post).

    eywalink:  /blog/<slug>, /en/blog/<slug>, /zh/blog/<slug> (± trailing /)
    mirror:    /YYYY/MM/DD/<slug>.html (legacy 4-seg) and /YYYY-MM-DD/<slug>
    """
    segs = [s for s in url_path.split("/") if s]
    if not segs:
        return None
    # eywalink blog path: must contain a 'blog' segment
    if "blog" in segs:
        i = segs.index("blog")
        if i + 1 < len(segs) and segs[i + 1]:
            return segs[i + 1].rstrip("/").rstrip(".html") or None
        return None
    # mirror dated path: /YYYY/... (legacy 4-seg) or /YYYY-MM-DD/<slug> (cutover)
    if len(segs) >= 2 and DATE_PREFIX.match(segs[0]):
        leaf = segs[-1].removesuffix(".html").rstrip("/")
        # Legacy double-dated URLs (e.g. /2026/08/16/2026-07-07-<slug>.html)
        # bake the post date into the leaf. The front-end keys on the clean
        # title slug (pathToSlug strips only a .html), so strip a leading
        # YYYY-MM-DD- / YYYY- prefix here to keep every URL generation of the
        # same post under ONE key instead of fragmenting the count.
        m = re.match(r"^\d{4}(?:-\d{2}-\d{2})?-[\w]", leaf)
        if m:
            leaf = leaf[m.end() - 1:]
        return leaf or None
    return None


def main():
    ids_in = ",".join(f"'{x}'" for x in SITES)
    sql = (
        "select e.url_path, count(*) "
        "from website_event e "
        f"where e.website_id in ({ids_in}) and e.event_type = 1 "
        "group by e.url_path;"
    )
    proc = subprocess.run(
        [
            "docker", "exec", "umami-db-1", "psql",
            "-U", "umami", "-d", "umami",
            "-t", "-A", "-F", "\t", "-c", sql,
        ],
        capture_output=True, text=True,
    )
    if proc.returncode != 0:
        sys.exit("umami_views_feed: psql failed: " + proc.stderr.strip())

    views = {}
    for line in proc.stdout.strip().split("\n"):
        if not line:
            continue
        url_path = line.split("\t")[0]
        count = int(line.split("\t")[1]) if "\t" in line else 0
        slug = url_to_slug(url_path)
        if slug:
            views[slug] = views.get(slug, 0) + count

    out = {
        "site": "terrygzhou.github.io",
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "views": dict(sorted(views.items(), key=lambda kv: kv[1], reverse=True)),
    }
    print(json.dumps(out, indent=2))


if __name__ == "__main__":
    main()
