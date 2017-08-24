<?php 
///
// NextcloudPi Web Panel backend
//
// Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
// GPL licensed (see end of file) * Use at your own risk!
//
// More at https://ownyourbits.com/2017/02/13/nextcloud-ready-raspberry-pi-image/
///

include ('csrf.php');

session_start();
ignore_user_abort( true );

if ( $_POST['action'] == "cfgreq" ) 
{
  if ( !$_POST['ref'] ) exit( '{ "output": "Invalid request" }' );

  //CSFR check
  $token = isset($_POST['csrf_token']) ? $_POST['csrf_token'] : '';
  if ( empty($token) || !validateCSRFToken($token) )
    exit( '{ "output": "Unauthorized request. Try reloading the page" }' );

  $path  = '/usr/local/etc/nextcloudpi-config.d/';
  $files = array_diff(scandir($path), array('.', '..'));

  $fh    = fopen( $path . $_POST['ref'] . '.sh' ,'r')
             or exit( '{ "output": "' . $file . ' read error" }' );

  // Get new token
  echo '{ "token": "' . getCSRFToken() . '",';
  echo ' "output": ';

  $output = "<table>";

  while ( $line = fgets($fh) ) 
  {
    // checkbox (yes/no) field
    if ( preg_match('/^(\w+)_=(yes|no)$/', $line, $matches) )
    {
      if ( $matches[2] == "yes" )
        $checked = "checked";
      $output = $output . "<tr>";
      $output = $output . "<td><label for=\"$matches[1]\">$matches[1]</label></td>";
      $output = $output . "<td><input type=\"checkbox\" id=\"$matches[1]\" name=\"$matches[1]\" value=\"$matches[2]\" $checked></td>";
      $output = $output . "</tr>";
    }

    // text field
    else if ( preg_match('/^(\w+)_=(.*)$/', $line, $matches) )
    {
      $output = $output . "<tr>";
      $output = $output . "<td><label for=\"$matches[1]\">$matches[1]</label></td>";
      $output = $output . "<td><input type=\"text\" name=\"$matches[1]\" id=\"$matches[1]\" value=\"$matches[2]\" size=\"40\"></td>";
      $output = $output . "</tr>";
    }
  }

  $output = $output . "</table>";
  fclose($fh);

  echo json_encode( $output ) . ' }'; // close JSON
}

else if ( $_POST['action'] == "launch" && $_POST['config'] )
{
  if ( !$_POST['ref'] ) exit( '{ "output": "Invalid request" }' );

  // CSRF check
  $token = isset($_POST['csrf_token']) ? $_POST['csrf_token'] : '';
  if ( empty($token) || !validateCSRFToken($token) )
    exit( '{ "output": "Unauthorized request. Try reloading the page" }' );

  chdir('/usr/local/etc/nextcloudpi-config.d/');

  $file = $_POST['ref'] . '.sh';

  if ( $_POST['config'] != "{}" )
    $params = json_decode( $_POST['config'], true )
                or exit( '{ "output": "Invalid request" }' );

  $code = file_get_contents( $file )
            or exit( '{ "output": "' . $file . ' read error" }' );

  foreach( $params as $name => $value) 
  {
    preg_match( '/^[\w.,@_\/-]+$/' , $value , $matches )
      or exit( '{ "output": "Invalid input" , "token": "' . getCSRFToken() . '" }' );
    $code = preg_replace( '/\n' . $name . '_=.*' . PHP_EOL . '/'  ,
                        PHP_EOL . $name . '_=' . $value . PHP_EOL ,
                        $code )
              or exit();
  }

  file_put_contents($file, $code )
    or exit( '{ "output": "' . $file . ' write error" }' );

  // Get new token
  echo '{ "token": "' . getCSRFToken() . '",';
  echo ' "output": "" , ';
  echo ' "ret": ';

  exec( 'bash -c "sudo /home/www/ncp-launcher.sh ' . $file . '"' , $output , $ret );
  echo '"' . $ret . '" }';
}

else if ( $_POST['action'] == "poweroff" )
{
  // CSRF check
  $token = isset($_POST['csrf_token']) ? $_POST['csrf_token'] : '';
  if ( empty($token) || !validateCSRFToken($token) )
    exit( '{ "output": "Unauthorized request. Try reloading the page" }' );
  shell_exec( 'bash -c "( sleep 2 && sudo halt ) 2>/dev/null >/dev/null &"' );
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
