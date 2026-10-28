<?php
$pageTitle = $pageTitle ?? 'IIUC Railway';
$activeUser = current_user();
$activeAdmin = current_admin();
?>
<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title><?=e($pageTitle)?> · IIUC Railway</title><link rel="stylesheet" href="<?=e(app_url('style.css'))?>"></head><body>
<header><a class="brand" href="<?=e(app_url('home.php'))?>">IIUC <b>Railway</b></a><nav>
<a href="<?=e(app_url('home.php'))?>">Home</a><a href="<?=e(app_url('train-information.php'))?>">Schedules</a><a href="<?=e(app_url('contact-us.php'))?>">Contact</a>
<?php if ($activeUser): ?><a href="<?=e(app_url('my-bookings.php'))?>">My bookings</a><form method="post" action="<?=e(app_url('logout.php'))?>"><?php csrf_input();?><button class="textbtn">Log out</button></form>
<?php elseif ($activeAdmin): ?><a href="<?=e(app_url('admin/index.php'))?>">Admin</a><form method="post" action="<?=e(app_url('admin/logout.php'))?>"><?php csrf_input();?><button class="textbtn">Log out</button></form>
<?php else: ?><a href="<?=e(app_url('login.php'))?>">Sign in</a><a class="button small" href="<?=e(app_url('register.php'))?>">Create account</a><?php endif ?>
</nav></header><main>
<?php if ($message = flash()): ?><div class="notice"><?=e($message)?></div><?php endif ?>
