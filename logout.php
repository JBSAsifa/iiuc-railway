<?php
require __DIR__.'/includes/bootstrap.php';
if($_SERVER['REQUEST_METHOD']!=='POST'){http_response_code(405);exit('Use the sign-out button.');}
check_csrf();unset($_SESSION['user']);session_regenerate_id(true);flash('You have signed out.');go('home.php');
