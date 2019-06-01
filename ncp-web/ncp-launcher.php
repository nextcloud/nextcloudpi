<?php 
///
// NextCloudPi Web Panel backend
//
// Copyleft 2018 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
// GPL licensed (see end of file) * Use at your own risk!
//
// More at https://nextcloudpi.com
///

include ('csrf.php');

ob_start();
session_start();
$cfg_dir = '/usr/local/etc/ncp-config.d/';
$l10nDir = "l10n";
ignore_user_abort(true);

// 
// language
//
require("L10N.php");
try {
  $l = new L10N($_SERVER["HTTP_ACCEPT_LANGUAGE"], $l10nDir, $cfg_dir);
} catch (Exception $e) {
  die(json_encode("<p class='error'>Error while loading localizations!</p>"));
}

// CSRF check
$token = isset($_POST['csrf_token']) ? $_POST['csrf_token'] : '';
if ( empty($token) || !validateCSRFToken($token) )
  exit( '{ "output": "Unauthorized request. Try reloading the page" }' );

//
// launch
//
if ( $_POST['action'] == "launch" && $_POST['config'] )
{
  // sanity checks
  if ( !$_POST['ref'] ) exit( '{ "output": "Invalid request" }' );

  $ncp_app = $_POST['ref'];

  preg_match( '/^[0-9A-Za-z_-]+$/' , $_POST['ref'] , $matches )
    or exit( '{ "output": "Invalid input" , "token": "' . getCSRFToken() . '" }' );

  // save new config
  if ( $_POST['config'] != "{}" )
  {
    $cfg_file = $cfg_dir . $ncp_app . '.cfg';

    $cfg_str = file_get_contents($cfg_file)
      or exit('{ "output": "' . $ncp_app . ' read error" }');

    $cfg = json_decode($cfg_str, true)
      or exit('{ "output": "' . $ncp_app . ' read error" }');

    $new_params = json_decode($_POST['config'], true)
      or exit('{ "output": "Invalid request" }');

    foreach ($cfg['params'] as $index => $param)
    {
      // don't touch missing parameters
      $id = $cfg['params'][$index]['id'];
      if (!array_key_exists($id, $new_params)) continue;

      // sanitize
      $val = trim(escapeshellarg($new_params[$id]),"'");
      preg_match( '/[\'" ]/' , $val , $matches )
        and exit( '{ "output": "Invalid parameters" , "token": "' . getCSRFToken() . '" }' );

      // save
      $cfg['params'][$index]['value'] = $val;
    }

    $cfg_str = json_encode($cfg)
      or exit('{ "output": "' . $ncp_app . ' internal error" }');

    file_put_contents($cfg_file, $cfg_str)
      or exit('{ "output": "' . $ncp_app . ' write error" }');
  }

  // launch
  echo '{ "token": "' . getCSRFToken() . '",';     // Get new token
  echo ' "ref": "' . $ncp_app          . '",';
  echo ' "output": "" , ';
  echo ' "ret": ';

  exec( 'bash -c "sudo /home/www/ncp-launcher.sh ' . $ncp_app . '"' , $output , $ret );
  echo '"' . $ret . '" }';
}

//
// info
//
else if ( $_POST['action'] == "info" )
{
  exec( 'bash /usr/local/bin/ncp-diag', $output, $ret );

  // info table
  $table = '<table class="dashtable">';
  foreach( $output as $line )
  {
    $table .= "<tr>";
    $fields = explode( "|", $line );
    $table .= "<td>$fields[0]</td>";

    $class = 'val-field';
    if ( strpos( $fields[1], "up"   ) !== false
      || strpos( $fields[1], "ok"   ) !== false
      || strpos( $fields[1], "open" ) !== false )
      $class = 'ok-field';
    if ( strpos( $fields[1], "down"  ) !== false
      || strpos( $fields[1], "error" ) !== false )
      $class = 'error-field';

    $table .= "<td class=\"$class\">$fields[1]</td>";
    $table .= "</tr>";
  }
  $table .= "</table>";

  // suggestions
  $suggestions = "";
  if ( $ret == 0 )
  {
    exec( "bash /usr/local/bin/ncp-suggestions \"" . implode( "\n", $output ) . '"', $out, $ret );
    foreach( $out as $line )
      if ( $line != "" )
        $suggestions .= "<p class=\"val-field\">‣ $line</p>";
  }

  // return JSON
  echo '{ "token": "' . getCSRFToken() . '",';               // Get new token
  echo ' "table": '       . json_encode( $table       ) . ' , ';
  echo ' "suggestions": ' . json_encode( $suggestions ) . ' , ';
  echo ' "ret": "'        . $ret                        . '" }';
}

//
// backups
//
else if ( $_POST['action'] == "backups" )
{
  ob_start();
  include('backups.php');
  $backups_page = ob_get_clean();

  // return JSON
  echo '{ "token": "' . getCSRFToken() . '",';               // Get new token
  echo ' "output": '      . json_encode($backups_page) . ' , ';
  echo ' "ret": "0" }';
}

//
// sidebar
//
else if ( $_POST['action'] == "sidebar" )
{
  require( "elements.php" );
  // return JSON
  echo '{ "token": "' . getCSRFToken() . '",';               // Get new token
  echo ' "output": '  . json_encode( print_sidebar( $l, true ) ) . ' , ';
  echo ' "ret": "0" }';
}

//
// cfg-ui
//
else if ( $_POST['action'] == "cfg-ui" )
{
  $ret = $l->save( $_POST['value'] );
  $ret = $ret !== FALSE ? 0 : 1;
  // return JSON
  echo '{ "token": "' . getCSRFToken() . '",';               // Get new token
  echo ' "ret": "'    . $ret           . '" }';
}

//
// path field
//
else if ( $_POST['action'] == "path-exists" )
{
  if (file_exists($_POST['value']))
    $ret = 0;
  else
    $ret = 1;

  // return JSON
  echo '{ "token": "' . getCSRFToken() . '",';               // Get new token
  echo ' "ret": "'    . $ret           . '" }';
}

//
// del backup
//
else if ( $_POST['action'] == "del-bkp" )
{
  $file = escapeshellarg($_POST['value']);
  $ret = 1;
  exec("sudo /home/www/ncp-backup-launcher.sh del $file", $out, $ret);

  // return JSON
  echo '{ "token": "' . getCSRFToken() . '",';               // Get new token
  echo ' "ret": "'    . $ret           . '" }';
}

//
// del snapshot
//
else if ( $_POST['action'] == "del-snap" )
{
  $file = escapeshellarg($_POST['value']);
  $ret = 1;
  exec("sudo /home/www/ncp-backup-launcher.sh delsnp $file", $out, $ret);

  // return JSON
  echo '{ "token": "' . getCSRFToken() . '",';               // Get new token
  echo ' "ret": "'    . $ret           . '" }';
}

//
// poweroff
//
else if ( $_POST['action'] == "poweroff" )
{
  shell_exec( 'bash -c "( sleep 2 && sudo halt ) 2>/dev/null >/dev/null &"' );
}

//
// reboot
//
else if ( $_POST['action'] == "reboot" )
{
  shell_exec('bash -c "( sleep 2 && sudo reboot ) 2>/dev/null >/dev/null &"');
}

// License
//
// This script is free software; you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This script is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this script; if not, write to the
// Free Software Foundation, Inc., 59 Temple Place, Suite 330,
// Boston, MA  02111-1307  USA
?>
