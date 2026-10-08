<?php
// views_feed.php — generate the blog all-time views JSON for terrygzhou.github.io.
//
// Runs INSIDE the matomo container (docker exec matomo php /tmp/views_feed.php)
// and queries the Matomo MariaDB directly, because this instance's public API
// plugin is not usable (every module=api call 404s with "The plugin api was
// not found"). DB credentials come from environment variables passed by
// refresh_views.sh (sourced from matomo-src/.env on the host) — so nothing
// secret is committed to this public repo.
//
// Output (stdout): {
//   "site": "terrygzhou.github.io",
//   "generated_at": "...",
//   "views": { "<post-path without leading slash>": <distinct-visit count> }
// }
// The page's [data-views-count] elements carry data-path="/<post-path>"; the JS
// strips the leading slash and looks the key up in "views".

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

// All-time distinct visits per URL for site 2 (terrygzhou.github.io).
// log_action.name holds the recorded URL name (host-prefixed, e.g.
// "terrygzhou.github.io/2026-10-02/some-post.html"). type=1 = pageviews.
$sql = "SELECT a.name AS url_name, COUNT(DISTINCT l.idvisit) AS n
        FROM log_action a
        JOIN log_link_visit_action l ON l.idaction_url = a.idaction
        JOIN log_visit v ON v.idvisit = l.idvisit
        WHERE v.idsite = 2 AND a.type = 1 AND l.idaction_url > 0
        GROUP BY a.name";

$views = [];
foreach ($pdo->query($sql) as $row) {
    $name = trim($row['url_name']);
    if ($name === '') continue;
    // Normalise to the page's data-path shape (path, no host, no leading slash).
    $name = preg_replace('#^https?://terrygzhou\.github\.io#i', '', $name);
    $name = preg_replace('#^terrygzhou\.github\.io#i', '', $name);
    $name = ltrim($name, '/');
    if ($name === '') {
        $name = 'index.html'; // bare "terrygzhou.github.io" / "terrygzhou.github.io/"
    }
    $views[$name] = ($views[$name] ?? 0) + (int)$row['n'];
}

// The Jekyll home page's data-path is "/" which the page script normalises
// to "" (empty) — alias the home count to that key so the featured card
// and home meta both resolve.
if (isset($views['index.html'])) {
    $views[''] = ($views[''] ?? 0) + $views['index.html'];
}

$out = [
    'site'         => 'terrygzhou.github.io',
    'generated_at' => gmdate('c'),
    'views'        => $views,
];

echo json_encode($out, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES), "\n";
