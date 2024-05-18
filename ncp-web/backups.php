<!--
 NextCloudPi Web Backups Panel

 Copyleft 2019 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
 GPL licensed (see end of file) * Use at your own risk!

 More at https://nextcloudpi.com
-->
<?php

$bkp_cfg      = file_get_contents('/usr/local/etc/ncp-config.d/nc-backup.cfg')      or exit('backup config not found');
$bkp_auto_cfg = file_get_contents('/usr/local/etc/ncp-config.d/nc-backup-auto.cfg') or exit('backup config not found');

$bkp_json      = json_decode($bkp_cfg     , true) or exit('invalid format');
$bkp_auto_json = json_decode($bkp_auto_cfg, true) or exit('invalid format');

$bkp_dir      = $bkp_json['params'][0]['value'];
$bkp_auto_dir = $bkp_auto_json['params'][1]['value'];

$bkps = array();
$bkps_auto = array();
exec("sudo /home/www/ncp-backup-launcher.sh listkopia", $bkps_kopia_raw, $ret);
if ( $ret !== 0 ) {
    die('Error fetching kopia backups');
}
$bkps_kopia=json_decode(join("\n", $bkps_kopia_raw), true) or exit('invalid format:');

function filesize_compat($file)
{
  if(PHP_INT_SIZE === 4) # workaround for 32-bit architectures
    return trim(shell_exec("stat -c%s " . escapeshellarg($file)));
  else
    return filesize($file);
}

if (file_exists($bkp_dir))
{
  $bkps = array_diff(scandir($bkp_dir), array('.', '..'));
  $bkps = preg_filter('/^/', $bkp_dir. '/', $bkps);
}

if (file_exists($bkp_auto_dir))
{
  $bkps_auto = array_diff(scandir($bkp_auto_dir), array('.', '..'));
  $bkps_auto = preg_filter('/^/', $bkp_auto_dir . '/', $bkps_auto);
}

$bkps = array_unique(array_merge($bkps, $bkps_auto));

if (!empty($bkps))
{
echo <<<HTML
  <div id="backups-table">
  <table class="dashtable backuptable">
  <th>Date</th><th>Size</th><th>Compressed</th><th>Data</th><th></th>
HTML;

  $cache_file = '/var/www/ncp-web/backup-info-cache.cfg';
  if (file_exists($cache_file)) {
    $cache_str = file_get_contents($cache_file)
      or exit("error opening ${cache_file}");

    $cache = json_decode($cache_str, true) or [];
  } else {
    $cache = [];
  }
  foreach ($bkps as $bkp) {
    $extension = pathinfo($bkp, PATHINFO_EXTENSION);
    if ($extension === "tar" || $extension === "gz")
    {
      $compressed = "";
      if ($extension === "gz")
        $compressed = '✓';

      $date = date("Y M d  @ H:i", filemtime($bkp));
      $size = round(filesize_compat($bkp)/1024/1024) . " MiB";

      $has_data = '';
      $ret = null;

      if (array_key_exists($bkp, $cache)) {
        $ret = $cache[$bkp];
        $cache_new[$bkp] = $ret;
      }

      if ($ret === null)
      {
        exec("sudo /home/www/ncp-backup-launcher.sh bkp " . escapeshellarg($bkp) . " \"$compressed\"", $output, $ret);
        $cache_new[$bkp] = $ret;
      }
      if ($ret == 0)
        $has_data = '✓';

      echo <<<HTML
      <tr id="$bkp">
        <td class="long-field" title="$bkp">$date&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
        <td class="val-field">$size</td>
        <td class="ok-field align-center">$compressed</td>
        <td class="ok-field align-center">$has_data</td>
        <td>
            <img class="hidden-btn default-btn download-bkp" title="download" src="../img/download.svg">
            <img class="hidden-btn default-btn delete-bkp"   title="delete"   src="../img/delete.svg">
            <img class="hidden-btn default-btn restore-bkp"  title="restore"  src="../img/defaults.svg">
        </td>
      </tr>
HTML;
      echo '<input type="hidden" name="csrf-token" value="' . getCSRFToken() . '"/>';
    }
  }
  $cache_str = json_encode($cache_new)
    or exit('internal error');

  file_put_contents($cache_file, $cache_str)
    or exit("error writing ${cache_file}");
echo <<<HTML
    </table>
  </div>
HTML;
} else {
  echo "<div>No backups found.</div>";
}
?>

</br></br>
<h2 class="text-title">Restore from file</h2>
<form action="upload.php" method="POST" enctype="multipart/form-data">
  <div class="restore-upload-btn-wrapper">
      <input type="file" name="backup" id="restore-upload" accept=".tar,.tar.gz"/>
      <input id="restore-upload-btn" type="submit" value="Restore"/>
  </div>
</form>
</br></br>

<h2 class="text-title"><?php echo $l->__("Snapshots"); ?></h2>

<?php

include( '/var/www/nextcloud/config/config.php' );

$snap_dir = realpath($CONFIG['datadirectory'] . '/../ncp-snapshots');
$snaps = array();
if (file_exists($snap_dir))
{
  $snaps = array_diff(scandir($snap_dir), array('.', '..'));
  $snaps = preg_filter('/^/', $snap_dir . '/', $snaps);
}

if (!empty($snaps))
{
echo <<<HTML
  <div id="snapshots-table">
  <table class="dashtable backuptable">
HTML;
  foreach ($snaps as $snap)
  {
    exec("sudo /home/www/ncp-backup-launcher.sh chksnp " . escapeshellarg($snap), $out, $ret);
    if ($ret == 0)
    {
      $snap_name = basename($snap);
      echo <<<HTML
      <tr id="$snap">
        <td class="text-align-left" title="$snap">$snap_name</td>
        <td>
            <img class="hidden-btn default-btn delete-snap"   title="delete"   src="../img/delete.svg">
            <img class="hidden-btn default-btn restore-snap"  title="restore"  src="../img/defaults.svg">
        </td>
      </tr>
HTML;
    }
  }
echo <<<HTML
    </table>
  </div>
HTML;
} else {
  echo "<div>No snapshots found.</div>";
}
?>
</br></br>
<h2 class="text-title"><?php echo $l->__("Kopia DB Backups"); ?></h2>
<div id="kopia-db-table">
  <table class="dashtable backuptable">
    <th>Date</th><th>Size</th><th></th>
    <?php
      foreach ($bkps_kopia as $bkp)
      {
          if ($bkp["source"]["path"] !== "/db") { continue; }
          $bkp_id = $bkp["id"];
          $bkp_time = $bkp["startTime"];
          $bkp_time = str_replace("T", " @ ", explode(".", $bkp_time)[0]);
          $bkp_size = $bkp["stats"]["totalSize"];
          $bkp_size_unit = "B";
          foreach (["KB", "MB", "GB", "TB"] as $unit) {
              if ($bkp_size < 1000) {
                  break;
              }
              $bkp_size = $bkp_size / 1000;
              $bkp_size_unit = "$unit";
          }
          echo <<<HTML
<tr id="$bkp_id"  data-snapshot-id="$bkp_id">
    <td class="text-align-left">$bkp_time</td>
    <td class="text-align-left">$bkp_size $bkp_size_unit</td>
    <td>
        <img class="hidden-btn default-btn delete-kopia-bkp"   title="delete"   src="../img/delete.svg"/>
        <img class="hidden-btn default-btn restore-kopia-bkp"  title="restore"  src="../img/defaults.svg"/>
    </td>
</tr>
HTML;

      }
    ?>
  </table>
</div>
</br>
<h2 class="text-title"><?php echo $l->__("Kopia Data Backups"); ?></h2>
<div id="kopia-data-table">
    <table class="dashtable backuptable">
        <th>Date</th><th>Size</th><th></th>
      <?php
      foreach ($bkps_kopia as $bkp)
      {
        if ($bkp["source"]["path"] !== "/ncdata") { continue; }
        $bkp_id = $bkp["id"];
        $bkp_time = $bkp["startTime"];
        $bkp_time = str_replace("T", " @ ", explode(".", $bkp_time)[0]);
        $bkp_size = $bkp["stats"]["totalSize"];
        $bkp_size_unit = "B";
        foreach (["KB", "MB", "GB", "TB"] as $unit) {
          if ($bkp_size < 1000) {
            break;
          }
          $bkp_size = $bkp_size / 1000;
          $bkp_size_unit = "$unit";
        }
        echo <<<HTML
<tr id="$bkp_id" data-snapshot-id="$bkp_id">
    <td class="text-align-left">$bkp_time</td>
    <td class="text-align-left">$bkp_size $bkp_size_unit</td>
    <td>
        <img class="hidden-btn default-btn delete-kopia-bkp"   title="delete"   src="../img/delete.svg"/>
        <img class="hidden-btn default-btn restore-kopia-bkp"  title="restore"  src="../img/defaults.svg"/>
    </td>
</tr>
HTML;

      }
      ?>
    </table>
</div>
<!--
 License

 This script is free software; you can redistribute it and/or modify it
 under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 This script is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this script; if not, write to the
 Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 Boston, MA  02111-1307  USA
-->
