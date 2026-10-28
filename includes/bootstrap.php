<?php
declare(strict_types=1);
$config = require __DIR__ . '/../config/config.php';
ini_set('display_errors', '0');
ini_set('log_errors', '1');
error_reporting(E_ALL);
if (session_status() !== PHP_SESSION_ACTIVE) {
    session_name((string)$config['session_name']);
    session_set_cookie_params([
        'lifetime' => 0, 'path' => (string)$config['base_url'] ?: '/',
        'secure' => !empty($_SERVER['HTTPS']), 'httponly' => true, 'samesite' => 'Lax'
    ]);
    session_start();
}
try {
    $dsn = 'mysql:host=' . $config['db_host'] . ';dbname=' . $config['db_name'] . ';charset=utf8mb4';
    $pdo = new PDO($dsn, (string)$config['db_user'], (string)$config['db_password'], [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ]);
} catch (PDOException $exception) {
    http_response_code(503);
    exit('The railway database is not available. Start MySQL, import database.sql, and check config/local.php.');
}
function e(mixed $value): string { return htmlspecialchars((string)$value, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8'); }
function app_url(string $file = 'home.php', array $query = []): string {
    global $config;
    $url = rtrim((string)$config['base_url'], '/') . '/' . ltrim($file, '/');
    return $url . ($query ? '?' . http_build_query($query) : '');
}
function go(string $file, array $query = []): void { header('Location: ' . app_url($file, $query)); exit; }
function csrf_token(): string { return $_SESSION['_csrf'] ??= bin2hex(random_bytes(32)); }
function check_csrf(): void {
    if (!hash_equals((string)($_SESSION['_csrf'] ?? ''), (string)($_POST['_csrf'] ?? ''))) {
        http_response_code(400); exit('This form expired. Reload the page and try again.');
    }
}
function flash(string $message = ''): string {
    if ($message !== '') { $_SESSION['_flash'] = $message; return ''; }
    $message = (string)($_SESSION['_flash'] ?? ''); unset($_SESSION['_flash']); return $message;
}
function current_user(): ?array { return $_SESSION['user'] ?? null; }
function current_admin(): ?array { return $_SESSION['admin'] ?? null; }
function require_user(): void { if (!current_user()) go('login.php'); }
function require_admin(): void { if (!current_admin()) go('admin/login.php'); }
function email_allowed(string $email): bool {
    global $config;
    $pattern = (string)$config['allowed_email_pattern'];
    return filter_var($email, FILTER_VALIDATE_EMAIL) !== false && @preg_match($pattern, $email) === 1;
}
function valid_journey_date(string $date): bool {
    $d = DateTimeImmutable::createFromFormat('!Y-m-d', $date);
    return $d !== false && $d->format('Y-m-d') === $date && $date >= date('Y-m-d');
}
function post_string(string $key, int $max = 255): string {
    $value = trim((string)($_POST[$key] ?? ''));
    return function_exists('mb_substr') ? mb_substr($value, 0, $max, 'UTF-8') : substr($value, 0, $max);
}
function csrf_input(): void { echo '<input type="hidden" name="_csrf" value="' . e(csrf_token()) . '">'; }

function valid_time(string $time): bool { $value = DateTimeImmutable::createFromFormat('!H:i', $time); return $value !== false && $value->format('H:i') === $time; }
