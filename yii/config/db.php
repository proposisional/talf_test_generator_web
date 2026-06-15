<?php

$db = [
    'class' => 'yii\\db\\Connection',
    'charset' => 'utf8',
];

if ($dsn = getenv('DB_DSN')) {
    $db['dsn'] = $dsn;
    $db['username'] = getenv('DB_USER') ?: (getenv('DB_USERNAME') ?: null);
    $db['password'] = getenv('DB_PASS') ?: (getenv('DB_PASSWORD') ?: null);
    return $db;
}

if ($databaseUrl = getenv('DATABASE_URL')) {
    $parts = parse_url($databaseUrl);

    $scheme = $parts['scheme'] ?? '';
    if ($scheme === 'postgres' || $scheme === 'postgresql') {
        $scheme = 'pgsql';
    }

    $host = $parts['host'] ?? 'localhost';
    $port = $parts['port'] ?? 5432;
    $dbName = ltrim($parts['path'] ?? '', '/');

    $db['dsn'] = sprintf('%s:host=%s;port=%d;dbname=%s', $scheme, $host, $port, $dbName);
    $db['username'] = $parts['user'] ?? null;
    $db['password'] = $parts['pass'] ?? null;

    return $db;
}

$db['dsn'] = 'mysql:host=' . (getenv('DB_HOST') ?: 'localhost')
    . ';port=' . (getenv('DB_PORT') ?: '3306')
    . ';dbname=' . (getenv('DB_NAME') ?: 'tfg_talf');
$db['username'] = getenv('DB_USER') ?: (getenv('DB_USERNAME') ?: 'root');
$db['password'] = getenv('DB_PASS') ?: (getenv('DB_PASSWORD') ?: '');
$db['charset'] = 'utf8mb4';

return $db;


