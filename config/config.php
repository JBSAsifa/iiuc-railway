<?php
declare(strict_types=1);
$localConfigFile = __DIR__ . '/local.php';
$localConfig = is_file($localConfigFile) ? require $localConfigFile : [];
$localConfig = is_array($localConfig) ? $localConfig : [];
return array_replace([
    'db_host' => getenv('IIUC_DB_HOST') ?: '127.0.0.1',
    'db_name' => getenv('IIUC_DB_NAME') ?: 'iiuc_railway_system',
    'db_user' => getenv('IIUC_DB_USER') ?: 'root',
    'db_password' => getenv('IIUC_DB_PASSWORD') !== false ? getenv('IIUC_DB_PASSWORD') : '',
    'base_url' => getenv('IIUC_BASE_URL') ?: '/iiuc-railway',
    'allowed_email_pattern' => getenv('IIUC_EMAIL_PATTERN') ?: '/^[A-Z0-9._%+\\-]+@iiuc\\.ac\\.bd$/i',
    'session_name' => 'IIUCRAILWAYSESSID',
], $localConfig);
