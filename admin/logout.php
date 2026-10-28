<?php
require_once __DIR__ . '/../includes/bootstrap.php';
if($_SERVER['REQUEST_METHOD']!=='POST'){http_response_code(405);exit('Use the sign-out button.');}check_csrf();unset($_SESSION['admin']);session_regenerate_id(true);flash('Admin session ended.');go('home.php');
