<?php
///
// NextcloudPi Web Panel CSRF protection library
//
// Inspired by http://blog.ircmaxell.com/2013/02/preventing-csrf-attacks.html
//
// Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
// GPL licensed (see end of file) * Use at your own risk!
//
// More at https://ownyourbits.com/2017/02/13/nextcloud-ready-raspberry-pi-image/
///

function getCSRFToken() 
{
  $nonce = base64_encode( random_bytes(32) );
  if (empty($_SESSION['csrf_tokens'])) 
    $_SESSION['csrf_tokens'] = array();

  $_SESSION['csrf_tokens'][$nonce] = true;
  return $nonce;
}

function validateCSRFToken($token) 
{
  if (isset($_SESSION['csrf_tokens'][$token])) 
  {
    unset($_SESSION['csrf_tokens'][$token]);
    return true;
  }
  return false;
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
