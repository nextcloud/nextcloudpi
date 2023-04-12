<?php
///
// NextcloudPi Web Panel backend
//
// Copyleft 2019 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
// GPL licensed (see end of file) * Use at your own risk!
//
// More at https://nextcloudpi.com
///

include ('csrf.php');
session_start();

// CSRF check
$token = isset($_POST['csrf_token']) ? $_POST['csrf_token'] : '';
if ( empty($token) || !validateCSRFToken($token) )
  exit( '{ "output": "Unauthorized request. Try reloading the page" }' );

isset($_FILES['backup']) or exit( '{ "output": "no upload" }' );

$error=$_FILES['backup']['error'];
if ($error !== 0) 
  exit( '{ "output": "upload error ' . $error . '" }' );

$file_name = $_POST['csrf_token'] . basename($_FILES['backup']['name']);
$file_name = str_replace('/', '', $file_name);
$file_size = $_FILES['backup']['size'];
$file_tmp  = $_FILES['backup']['tmp_name'];
$file_type = $_FILES['backup']['type'];

preg_match( '/\.\./' , $file_name, $matches )
  and exit( '{ "output": "Invalid input" , "token": "' . getCSRFToken() . '" }' );

if($file_size === 0)
  $errors[]='No file';

$extension = pathinfo($file_name, PATHINFO_EXTENSION);
if ($extension !== "tar" and $extension !== "gz")
  exit( '{ "output": "invalid file" }' );

if (!move_uploaded_file($file_tmp, '/tmp/' . $file_name))
  exit('{ "output": "upload denied" }');

// return JSON
echo '{ "token": "' . getCSRFToken() . '",';               // Get new token
echo ' "ret": "0" }';
?>
