<?php
$user=getenv('MATOMO_DB_USER')?:'matomo';$pass=getenv('MATOMO_DB_PASSWORD');$db=getenv('MATOMO_DB_NAME')?:'matomo';$host=getenv('MATOMO_DB_HOST')?:'mariadb';
$pdo=new PDO("mysql:host={$host};dbname={$db};charset=utf8mb4",$user,$pass);
$pdo->setAttribute(PDO::ATTR_ERRMODE,PDO::ERRMODE_EXCEPTION);
echo "=== sample a.name in the 23:35:06 burst (site2), with counts ===\n";
$q="SELECT a.name, a.type, COUNT(*) c FROM log_link_visit_action l JOIN log_action a ON a.idaction=l.idaction_url WHERE l.idsite=2 AND l.server_time='2026-10-09 23:35:06' AND a.type=1 GROUP BY a.name,a.type ORDER BY c DESC LIMIT 12";
foreach($pdo->query($q) as $r) echo "  [t".$r['type']."] ". $r['name'].": ".$r['c']."\n";
echo "\n=== same for site1 ===\n";
$q2="SELECT a.name, a.type, COUNT(*) c FROM log_link_visit_action l JOIN log_action a ON a.idaction=l.idaction_url WHERE l.idsite=1 AND l.server_time='2026-10-09 23:35:06' AND a.type=1 GROUP BY a.name,a.type ORDER BY c DESC LIMIT 12";
foreach($pdo->query($q2) as $r) echo "  [t".$r['type']."] ". $r['name'].": ".$r['c']."\n";
echo "\n=== how many burst rows have a.name containing '/' (post-like) vs not? (site2) ===\n";
$q3="SELECT SUM(a.name LIKE '%/%') with_slash, SUM(a.name NOT LIKE '%/%') no_slash, COUNT(*) tot FROM log_link_visit_action l JOIN log_action a ON a.idaction=l.idaction_url WHERE l.idsite=2 AND l.server_time='2026-10-09 23:35:06' AND a.type=1";
$r=$pdo->query($q3)->fetch(PDO::FETCH_ASSOC); echo "  with_slash=". $r['with_slash']." no_slash=". $r['no_slash']." total=". $r['tot']."\n";
