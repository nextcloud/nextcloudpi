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
$token = isset($_REQUEST['token']) ? $_REQUEST['token'] : '';
if ( empty($token) || !validateCSRFToken($token) )
  exit('Unauthorized download');

$file = '/var/log/ncp.log';

if (!file_exists($file))
    die('File not found');

if (!is_readable($file))
    die('NCP does not have read permissions on this file');

function filesize_compat($file)
{
  if(PHP_INT_SIZE === 4) # workaround for 32-bit architectures
    return trim(shell_exec("stat -c%s " . escapeshellarg($file)));
  else
    return filesize($file);
}

$size = filesize_compat($file);

$mime_type = 'text/plain';

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

if($size > $chunksize || PHP_INT_SIZE === 4) # always chunk for 32-bit architectures
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
