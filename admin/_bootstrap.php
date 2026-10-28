<?php
require_once __DIR__ . '/../includes/bootstrap.php';
require_admin();
function admin_password_valid(string $password): bool { return strlen($password)>=12 && strlen($password)<=200; }
