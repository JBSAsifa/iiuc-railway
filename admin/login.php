<?php
require_once __DIR__ . '/../includes/bootstrap.php';
if(current_admin())go('admin/index.php');
if($_SERVER['REQUEST_METHOD']==='POST'){check_csrf();$email=strtolower(trim((string)($_POST['email']??'')));$q=$pdo->prepare('SELECT admin_id,full_name,email,password_hash,is_active FROM admin_users WHERE email=? LIMIT 1');$q->execute([$email]);$a=$q->fetch();if($a&&$a['is_active']&&password_verify((string)($_POST['password']??''),$a['password_hash'])){session_regenerate_id(true);unset($_SESSION['user']);unset($a['password_hash'],$a['is_active']);$_SESSION['admin']=$a;go('admin/index.php');}flash('Admin email or password was not recognized.');go('admin/login.php');}
$pageTitle='Admin sign in';require __DIR__.'/../includes/header.php';?>
<section class="auth"><span class="eyebrow">ADMINISTRATION</span><h1>Admin sign in</h1><p>Authorized administrators only.</p><form method="post" class="fields"><?php csrf_input();?><label>Admin email<input required type="email" name="email" autocomplete="username"></label><label>Password<input required type="password" name="password" autocomplete="current-password"></label><button class="button">Sign in</button></form></section>
<?php require __DIR__.'/../includes/footer.php'; ?>
