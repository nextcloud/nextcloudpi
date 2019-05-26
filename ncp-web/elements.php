<?php
///
// NextCloudPi Web Panel Side bar
//
// Copyleft 2018 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
// GPL licensed (see end of file) * Use at your own risk!
//
// More at https://ownyourbits.com/2017/02/13/nextcloud-ready-raspberry-pi-image/
///

// fill options with contents from directory

function print_config_form( $ncp_app, $cfg, $l )
{
  $ret  = <<<HTML
    <div id="config-box">
      <form>
        <table>
HTML;

  foreach ($cfg['params'] as $param)
  {
    $ret .= "<tr>";
    $ret .= "<td><label for=\"$ncp_app-$param[id]\">$param[name]</label></td>";

    $value = $param['value'];
    if ( $value == '_')
      $value = '';

    // default to text input
    if (!array_key_exists('type', $param) || $param['type'] == 'directory' || $param['type'] == 'file')
    {
      $suggest = '';
      if (array_key_exists('suggest', $param))
        $suggest = $param['suggest'];

      $default = '';
      if (array_key_exists('default', $param))
        $default = $param['default'];

      $class = '';
      if (array_key_exists('type', $param) && ($param['type'] == 'directory' || $param['type'] == 'file'))
        $class = $param['type'];

      $ret .= "<td>
                <input type=\"text\"
                  id=\"$ncp_app-$param[id]\"
                  name=\"$param[name]\"
                  class=\"$class\"
                  value=\"$value\"
                  default=\"$default\"
                  placeholder=\"$suggest\"
                size=\"40\">";

      if (array_key_exists('default', $param))
        $ret .= "&nbsp;<img class=\"default-btn\" title=\"restore defaults\" src=\"../img/defaults.svg\">";

      if (array_key_exists('type', $param) && $param['type'] == 'directory')
      {
        if (file_exists($value))
          $ret .= "&nbsp;<span class=\"ok-field\">path exists</span>";
        else
          $ret .= "&nbsp;<span class=\"error-field\">path doesn't exist</span>";
      }

      if (array_key_exists('type', $param) && $param['type'] == 'file')
      {
        if (file_exists(dirname($value)))
          $ret .= "&nbsp;<span class=\"ok-field\">path exists</span>";
        else
          $ret .= "&nbsp;<span class=\"error-field\">path doesn't exist</span>";
      }

      $ret .= "</td>";
    }

    // checkbox
    else if ($param['type'] == 'bool')
    {
      $checked = "";
      if ($value == 'yes')
        $checked = 'checked';
      $ret .= "<td><input type=\"checkbox\"
                  id=\"$ncp_app-$param[id]\"
                  name=\"$param[name]\"
                  value=\"$value\"
                  $checked>
                </td>";
    }

    // password
    else if ($param['type'] == 'password')
    {
      $ret .= "<td>";
      $ret .= "<input type=\"password\"
                name=\"$param[name]\"
                id=\"$ncp_app-$param[id]\"
                value=\"$value\"
              size=\"40\">";
      $ret .= "&nbsp;<img class=\"pwd-btn\" title=\"show password\" src=\"../img/toggle.svg\">";
      $ret .= "</td>";
    }

    $ret .= "</tr>";
  }

  $ret .= <<<HTML
      </table>
    </div>
    <div class="config-button-wrapper">
      <button id="$ncp_app-config-button" class="config-button">Apply</button>
      <img class="loading-gif" src="img/loading-small.gif">
      <div class="circle-retstatus icon-red-circle"></div>
    </div>
  </form>
HTML;
  return $ret;
}

function print_config_forms( $l /* translations l10n object */ )
{
  $bin_dir    = '/usr/local/bin/ncp/';
  $cfg_dir    = '/usr/local/etc/ncp-config.d/';
  $d_iterator = new RecursiveDirectoryIterator($bin_dir);
  $iterator   = new RecursiveIteratorIterator($d_iterator);

  $ret      = "";
  $sections = array_diff(scandir($bin_dir), array('.', '..', 'l10n'));
  foreach ($sections as $section)
  {
    $scripts = array_diff(scandir($bin_dir . $section), array('.', '..', 'nc-wifi.sh', 'nc-info.sh'));
    foreach ($scripts as $script)
    {
      $ncp_app  = pathinfo($script, PATHINFO_FILENAME);
      $cfg_file = $cfg_dir . $ncp_app . ".cfg";
      $cfg      = json_decode(file_get_contents($cfg_file), true);

      $hidden = 'hidden';
      if (array_key_exists('app',$_GET) && $_GET['app'] == $ncp_app)
        $hidden = '';
      $ret .= <<<HTML
        <div id="$cfg[id]-config-box" class="content-box $hidden">
          <h2 class="text-title">$cfg[description]</h2>
          <div class="config-box-info-txt">$cfg[info]</div>
          <a href="https://docs.nextcloudpi.com/en/configuration-reference/#$ncp_app" target="_blank">
            <div class="icon-info"></div>
          </a>
          <br/>
          <div class="table-wrapper">
HTML;

      $ret .= print_config_form($ncp_app, $cfg, $l);
      $ret .= <<<HTML
            <div id="$ncp_app-details-box" class="details-box outputbox hidden"></div>
          </div>
        </div>
HTML;
    }
  }
  return $ret;
}

function print_sidebar( $l /* translations l10n object */, $ticks /* wether to calculate ticks(slow) */ )
{
  $bin_dir    = '/usr/local/bin/ncp/';
  $cfg_dir    = '/usr/local/etc/ncp-config.d/';
  $d_iterator = new RecursiveDirectoryIterator($bin_dir);
  $iterator   = new RecursiveIteratorIterator($d_iterator);

  $ret      = "";
  $sections = array_diff(scandir($bin_dir), array('.', '..', 'l10n'));
  foreach ($sections as $section)
  {
    $ret .= "<li id=\"$section\"><span>{$l->__($section, $section)}</span>";

    $scripts = array_diff(scandir($bin_dir . $section), array('.', '..', 'nc-wifi.sh', 'nc-info.sh'));
    foreach ($scripts as $script)
    {
      $ncp_app  = pathinfo($script, PATHINFO_FILENAME);
      $cfg_file = $cfg_dir . $ncp_app . ".cfg";
      $cfg      = json_decode(file_get_contents($cfg_file), true);

      $active = "";
      if ( $ticks ) {
        exec("bash -c \"source /usr/local/etc/library.sh && is_active_app $ncp_app\"", $output, $retval);
        if ($retval == 0)
          $active = " ✓";
      } else if (sizeof($cfg['params']) > 0 && $cfg['params'][0]['id'] == 'ACTIVE' && $cfg['params'][0]['value'] == 'yes')
        $active = " ✓";

      $selected = "";
      if (array_key_exists('app',$_GET) && $_GET['app'] == $ncp_app)
        $selected = "active";
      $ret .= "<ul id=\"$ncp_app\" class=\"ncp-app-list-item $selected\">";
      $ret .=   "<a href=\"?app=$ncp_app\"> {$l->__($ncp_app, $ncp_app)}$active </a>";
      $ret .= "</ul>";
    }
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
