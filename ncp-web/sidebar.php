<?php
///
// NextcloudPlus Web Panel Side bar
//
// Copyleft 2018 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
// GPL licensed (see end of file) * Use at your own risk!
//
// More at https://ownyourbits.com/2017/02/13/nextcloud-ready-raspberry-pi-image/
///

// fill options with contents from directory

function print_sidebar( $l /* translations l10n object */, $ticks /* wether to calculate ticks(slow) */ )
{
  $modules_path = '/usr/local/etc/nextcloudpi-config.d/';
  $files = array_diff(scandir($modules_path), array('.', '..', 'nc-wifi.sh', 'nc-info.sh', 'l10n'));
  $ret   = "";

  foreach ($files as $file) {
    $script = pathinfo($file, PATHINFO_FILENAME);
    $txt = file_get_contents($modules_path . $file);

    $active = "";
    if ( $ticks ) {
      $etc = '/usr/local/etc';
      exec("bash -c \"source $etc/library.sh && is_active_script $etc/nextcloudpi-config.d/$script\".sh", $output, $retval);
      if ($retval == 0)
        $active = " ✓";
    } else if (preg_match('/^ACTIVE_=yes$/m', $txt, $matches))
        $active = " ✓";

    $ret .= "<li id=\"$script\" class=\"nav-recent\">";
    $ret .= "<a href=\"#\"> {$l->__($script, $script)}$active </a>";

    if (preg_match('/^DESCRIPTION="(.*)"$/m', $txt, $matches))
      $ret .= "<input id=\"$script-desc\" type=\"hidden\" value=\"{$l->__($matches[1], $script)}\" />";

    if (preg_match('/^INFO="(.*)"/msU', $txt, $matches))
      $ret .= "<input id=\"$script-info\" type=\"hidden\" value=\"{$l->__($matches[1], $script)}\" />";

    if (preg_match('/^INFOTITLE="(.*)"/msU', $txt, $matches))
      $ret .= "<input id=\"$script-infotitle\" type=\"hidden\" value=\"{$l->__($matches[1], $script)}\" />";

    $ret .= "</li>";
  }
  return $ret;
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
