<?php
declare(strict_types=1);
if(PHP_SAPI!=='cli'){http_response_code(404);exit('Not found.');}
require __DIR__.'/../includes/bootstrap.php';
if((int)$pdo->query('SELECT COUNT(*) FROM admin_users')->fetchColumn()>0){fwrite(STDERR,"An admin account already exists. Sign in and use Admin credentials to manage accounts.\n");exit(1);}
function ask(string $label): string { fwrite(STDOUT,$label);$line=fgets(STDIN);return trim($line===false?'':$line); }
$name=ask('Admin full name: ');$email=strtolower(ask('Admin email: '));
$canHide=function_exists('posix_isatty')&&posix_isatty(STDIN)&&function_exists('shell_exec');$stty='';if($canHide){$stty=trim((string)shell_exec('stty -g'));if($stty!=='')shell_exec('stty -echo');}
$password=ask('Admin password (12+ characters): ');
if($canHide&&$stty!==''){shell_exec('stty '.escapeshellarg($stty));fwrite(STDOUT,"\n");}
if($name===''||!filter_var($email,FILTER_VALIDATE_EMAIL)||strlen($password)<12){fwrite(STDERR,"Use a name, valid email, and password of at least 12 characters. No account was created.\n");exit(1);}
$q=$pdo->prepare('INSERT INTO admin_users(full_name,email,password_hash) VALUES(?,?,?)');$q->execute([$name,$email,password_hash($password,PASSWORD_DEFAULT)]);fwrite(STDOUT,"Initial admin created. Sign in at /iiuc-railway/admin/login.php\n");
