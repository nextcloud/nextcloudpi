<?php
///
// NextCloudPi Web Panel backend
//
// Copyleft 2019 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
// GPL licensed (see end of file) * Use at your own risk!
//
// More at https://nextcloudpi.com
///

include ('csrf.php');
session_start();

// CSRF check
$token = isset($_REQUEST['token']) ? $_REQUEST['token'] : '';
if ( empty($token) || !validateCSRFToken($token) )
  exit('Unauthorized download');

if (!isset($_REQUEST["bkp"]))
  die();

$file = $_REQUEST["bkp"];

if (!file_exists($file))
    die('File not found');

if (!is_readable($file))
    die('NCP does not have read permissions on this file');

$size = filesize($file);

$extension = pathinfo($file, PATHINFO_EXTENSION);
if ($extension === "tar" )
  $mime_type = 'application/x-tar';
else if( $extension === "gz")
  $mime_type = 'application/x-gzip';
else
  die();

ob_start();
ob_clean();
header('Content-Description: File Transfer');
header('Content-Type: ' . $mime_type);
header("Content-Transfer-Encoding: Binary"); 
header("Content-disposition: attachment; filename=\"" . basename($file) . "\"");
header('Content-Length: ' . $size);
header('Expires: 0');
header('Cache-Control: must-revalidate');
header('Pragma: public');

$chunksize = 8 * (1024 * 1024);
if($size > $chunksize)
{
  $handle = fopen($file, 'rb') or die("Error opening file");

  while (!feof($handle))
  { 
    $buffer = fread($handle, $chunksize);
    echo $buffer;

    ob_flush();
    flush();
  } 

  fclose($handle); 
}
else
  readfile($file);

ob_flush();
flush();

exit();

?>
