<?php
// views_feed.php — generate the combined all-time pageview JSON for the blog.
//
// Runs INSIDE the matomo container (docker exec matomo php /tmp/views_feed.php)
// and queries the Matomo MariaDB directly, because this instance's public API
// plugin is not usable (every module=api call 404s with "The plugin api was
// not found"). DB credentials come from environment variables passed by
// refresh_views.sh (sourced from matomo-src/.env on the host) — so nothing
// secret is committed to this public repo.
//
// THIS IS THE SINGLE SOURCE OF TRUTH for the blog pageview counter. Both
// fronts read the same JSON it emits, so a single post shows ONE number that
// grows no matter which domain the reader used:
//
//   * terrygzhou.github.io (this Jekyll mirror, site 2) — same-origin fetch of
//     assets/views-data.json, refreshed hourly by refresh_views.sh (git push
//     to GitHub Pages).
//   * eywalink.org (the Astro/Cloudflare main site, site 1) — cross-origin
//     fetch of the very same file (GitHub Pages serves access-control-allow-
//     origin: *), with its own baked copy as an offline fallback.
//
// Counts
// ──────
// Pageviews (raw `log_link_visit_action` type=1 rows referenced via
// `idaction_url`), summed across BOTH idsite=1 (eywalink.org) and idsite=2
// (terrygzhou.github.io), keyed by POST SLUG. No offsets/boosts — the number
// is the real combined pageview total. (The old version read site 2 only,
// counted distinct visits, and layered on views_offsets.json boosts — that
// inflated "56" is gone.)
//
// Slug resolution (rename-proof, matches on the stable URL path):
//   site 1 eywalink  →  eywalink.org[/en|/zh]/blog/<slug>/
//   site 2 mirror    →  terrygzhou.github.io/YYYY/MM/DD/<slug>.html
// Both reduce to the same last-segment slug, so a post cross-posted to both
// domains lands under one key.
//
// Output (stdout): {
//   "site": "terrygzhou.github.io",
//   "generated_at": "...",
//   "views": { "<slug>": <combined-pageview count> }
// }
// The page's [data-views-count] elements carry data-slug="<slug>"; the JS
// looks the key up in "views".

$user = getenv('MATOMO_DB_USER') ?: 'matomo';
$pass = getenv('MATOMO_DB_PASSWORD');
$db   = getenv('MATOMO_DB_NAME') ?: 'matomo';
$host = getenv('MATOMO_DB_HOST') ?: 'mariadb'; // docker service name

if ($pass === null || $pass === '') {
    fwrite(STDERR, "MATOMO_DB_PASSWORD not set\n");
    exit(1);
}

try {
    $pdo = new PDO("mysql:host={$host};dbname={$db};charset=utf8mb4", $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (Exception $e) {
    fwrite(STDERR, "db connect failed: {$e->getMessage()}\n");
    exit(1);
}

// Combined all-time pageviews per slug across both sites (site 1 + site 2).
//
// Site 1 (eywalink.org) — blog pages: eywalink.org/blog/<slug> (plus optional
// /en/ /zh/ locale prefixes). Slug = last path segment after /blog/, minus an
// optional trailing slash. The bare index (/blog/) yields an empty slug and
// is dropped below (per-post counters only).
//
// Site 2 (mirror) — dated post paths terrygzhou.github.io/YYYY/MM/DD/<slug>.html
// (a 4-segment date-path ending in .html). Slug = last segment minus .html.
//
// We match each site's URL shape with LIKE (no regex → no backslash escaping
// pain) and sum pageviews per slug, then merge the two per-slug maps.
$sql = "
WITH s1 AS (
    SELECT TRIM(TRAILING '/' FROM SUBSTRING_INDEX(a.name, '/blog/', -1)) AS slug,
           COUNT(*) AS views
    FROM log_link_visit_action l
    JOIN log_action a ON a.idaction = l.idaction_url
    WHERE l.idsite = 1 AND a.type = 1 AND l.idaction_url > 0
      AND (
            a.name LIKE 'eywalink.org/blog/%'
         OR a.name LIKE 'eywalink.org/en/blog/%'
         OR a.name LIKE 'eywalink.org/zh/blog/%'
      )
    GROUP BY 1
),
s2 AS (
    SELECT REPLACE(SUBSTRING_INDEX(a.name, '/', -1), '.html', '') AS slug,
           COUNT(*) AS views
    FROM log_link_visit_action l
    JOIN log_action a ON a.idaction = l.idaction_url
    WHERE l.idsite = 2 AND a.type = 1 AND l.idaction_url > 0
      AND a.name LIKE 'terrygzhou.github.io/%/%/%/%.html'
    GROUP BY 1
)
SELECT COALESCE(s1.slug, s2.slug) AS slug,
       IFNULL(s1.views, 0) + IFNULL(s2.views, 0) AS views
FROM s1 LEFT JOIN s2 ON s1.slug = s2.slug
UNION
SELECT COALESCE(s1.slug, s2.slug),
       IFNULL(s1.views, 0) + IFNULL(s2.views, 0)
FROM s2 LEFT JOIN s1 ON s1.slug = s2.slug
WHERE s1.slug IS NULL
ORDER BY views DESC";

$views = [];
foreach ($pdo->query($sql) as $row) {
    $slug = trim($row['slug']);
    if ($slug === '') {
        continue; // blog index / any host-less page — not a post
    }
    $views[$slug] = ($views[$slug] ?? 0) + (int)$row['views'];
}

$out = [
    'site'         => 'terrygzhou.github.io',
    'generated_at' => gmdate('c'),
    'views'        => $views,
];

echo json_encode($out, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES), "\n";
