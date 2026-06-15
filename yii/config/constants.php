<?php

// App root
if (!defined('APP_ROOT')) {
    define('APP_ROOT', dirname(__DIR__));
}

// Octave scripts path
if (!defined('OCTAVE_SCRIPTS_PATH')) {
    define('OCTAVE_SCRIPTS_PATH', APP_ROOT . DIRECTORY_SEPARATOR . 'octave');
}

if (!defined('OCTAVE_SCRIPT_EXTENSION')) {
    define('OCTAVE_SCRIPT_EXTENSION', '.m');
}

// Database parameters
if (!defined('APP_DB_HOST'))
    define('APP_DB_HOST', getenv('DB_HOST') ?: '127.0.0.1');
if (!defined('APP_DB_PORT'))
    define('APP_DB_PORT', getenv('DB_PORT') ?: '3306');
if (!defined('APP_DB_NAME'))
    define('APP_DB_NAME', getenv('DB_NAME') ?: 'yii');
if (!defined('APP_DB_USER'))
    define('APP_DB_USER', getenv('DB_USER') ?: 'root');
if (!defined('APP_DB_PASS'))
    define('APP_DB_PASS', getenv('DB_PASS') ?: '');


// Octave binary path
if (!defined('OCTAVE_BIN')) {
    $octaveBin = getenv('OCTAVE_BIN');
    if (!$octaveBin) {
        $isWindows = strtoupper(substr(PHP_OS, 0, 3)) === 'WIN';
        if ($isWindows) {
            $out = @shell_exec('where octave-cli 2>nul');
            if (!$out) {
                $out = @shell_exec('where octave 2>nul');
            }
            if ($out) {
                $lines = preg_split('/\r?\n/', trim($out));
                $octaveBin = $lines[0] ?? null;
            }
        } else {
            $out = @shell_exec('command -v octave-cli 2>/dev/null');
            if (!$out) {
                $out = @shell_exec('command -v octave 2>/dev/null');
            }
            if ($out) {
                $octaveBin = trim($out);
            }
        }
    }
    if (!$octaveBin) {
        $octaveBin = 'octave';
    }
    define('OCTAVE_BIN', $octaveBin);
}