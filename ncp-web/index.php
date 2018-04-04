<!--
 NextcloudPi Web Panel frontend

 Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
 GPL licensed (see end of file) * Use at your own risk!

 More at https://ownyourbits.com/2017/02/13/nextcloud-ready-raspberry-pi-image/
-->

<!DOCTYPE html>
<html class="ng-csp" data-placeholder-focus="false" lang="en">
<head>
    <meta charset="utf-8">
    <title>NextCloudPi Panel</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="referrer" content="never">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0">
    <meta name="mobile-web-app-capable" content="yes">
  <?php
    // redirect to activation first time
    exec("a2query -s ncp-activation", $output, $ret);
    if ($ret == 0) {
      header("Location: activate");
      exit();
    }
    session_start();

    include('sidebar.php');
    $modules_path = '/usr/local/etc/nextcloudpi-config.d/';
    $l10nDir = "l10n";

    // security headers
    header("Content-Security-Policy: default-src 'none'; script-src 'self'; connect-src 'self'; img-src 'self'; style-src 'self'; object-src 'self';");
    header("X-XSS-Protection: 1; mode=block");
    header("X-Content-Type-Options: nosniff");
    header("X-Robots-Tag: none");
    header("X-Permitted-Cross-Domain-Policies: none");
    header("X-Frame-Options: DENY");
    header("Cache-Control: max-age=15778463");
    ini_set('session.cookie_httponly', 1);
    if (isset($_SERVER['HTTPS']))
      ini_set('session.cookie_secure', 1);

    // HTTP2 push headers
    header("Link: </minified.js>; rel=preload; as=script;,</ncp.js>; rel=preload; as=script;,</ncp.css>; rel=preload; as=style;,</img/ncp-logo.svg>; rel=preload; as=image;, </img/loading-small.gif>; rel=preload; as=image;, rel=preconnect href=ncp-launcher.php;");

  ?>
    <link rel="icon" type="image/png" href="img/favicon.png"/>
    <link rel="stylesheet" href="ncp.css">
</head>
<body id="body-user">
<?php
  require("L10N.php");
  try {
    $l = new L10N($_SERVER["HTTP_ACCEPT_LANGUAGE"], $l10nDir, $modules_path);
  } catch (Exception $e) {
    die("<p class='error'>Error while loading localizations!</p>");
  }
?>
<noscript>
    <div id="nojavascript">
        <div>
          <?php sprintf($l->__("This application requires JavaScript for correct operation. Please %s enable JavaScript %s and reload the page."),
              "<a href=\"http://enable-javascript.com/\" target=\"_blank\" rel=\"noreferrer\">", "</a>"); ?>
        </div>
    </div>
</noscript>
<div id="notification-container">
  <?php
    exec("ncp-test-updates", $output, $ret);
    if ($ret == 0) {
      echo '<div id="notification">';
      echo '<div id="update-notification" class="row type-error closeable">';
      echo "version " . file_get_contents( "/var/run/.ncp-latest-version" ) . " is available";
      echo '<a class="action close icon-close" href="#" alt="Dismiss"></a>';
      echo '</div>';
      echo '</div>';
    }
  ?>
</div>

<?php
  if (file_exists('wizard') && !file_exists('wizard.cfg')) {
    echo <<<HTML
    <div id="first-run-wizard">
      <div class='dialog'>
        <br>
        <h2 id="config-box-title">NextCloudPi First Run</h2>
        <p>Click to start the configuration wizard</p>
        <br>
        <a href="wizard"><img class="wizard-btn" src="wizard/img/ncp-logo.svg" class="wizard"></a>
        <br>
        <button type="button" class="wizard-btn"      id="go-wizard"   >{$l->__("run")}  </button>
        <button type="button" class="first-run-close" id="skip-wizard" >{$l->__("skip")} </button>
        <button type="button" class="first-run-close" id="close-wizard">{$l->__("close")}</button>
        <br><br>
      </div>
    </div>
HTML;
    touch('wizard.cfg');
  }
?>

  <header role="banner"><div id="header">
    <div id="header-left">
      <a href="https://ownyourbits.com" id="nextcloudpi" target="_blank" tabindex="1">
        <div class="logo-icon">
           <h1 class="hidden-visually">NextCloudPi</h1>
        </div>
      </a>
      <a id=versionlink target="_blank" href="https://github.com/nextcloud/nextcloudpi/blob/master/changelog.md">
        <?php echo file_get_contents( "/usr/local/etc/ncp-version" ) ?>
      </a>
    </div>
    <div id="header-right">
      <a href="https://ownyourbits.com" id="nextcloud-btn" target="_blank" tabindex="1">
        <div id="nc-button">
            <div id="expand">
                <div class="icon-nc-white"></div>
            </div>
        </div>
      </a>
      <div id="dashboard-btn">
          <div id="expand">
              <div class="icon-dashboard"></div>
          </div>
      </div>
<?php 
  if ( file_exists( 'wizard' ) )
    echo <<<HTML
      <a href="wizard">
        <div class="wizard-btn">
          <div id="expand">
            <div class="icon-wizard-white"></div>
          </div>
        </div>
      </a>
HTML;
?>
      <div id="config-btn">
          <div id="expand">
              <div class="icon-config"></div>
          </div>
      </div>
      <a href="https://github.com/nextcloud/nextcloudpi/wiki" target="_blank" tabindex="1">
        <div id="nc-button">
            <div id="expand">
                <div class="icon-nc-info"></div>
            </div>
        </div>
      </a>
      <div id="poweroff">
          <div id="expand">
              <div class="icon-power-white"></div>
          </div>
      </div>
  </div>
</header>

  <div id="content-wrapper">
	<div id="content" class="app-files" role="main">
        <div id='overlay' class="hidden"></div>
		<div id="app-navigation">
        	<ul id="ncp-options">
              <?php echo print_sidebar($l); ?>
            </ul>
          </div>

      <div id="app-content">
        <div id="app-navigation-toggle" class="icon-menu hidden"></div>

        <div id="config-wrapper" class="hidden">
          <h2 id="config-box-title" class="text-title"><?php echo $l->__("System Info"); ?></h2>
          <div id="config-box-info-txt"></div>
          <a href="#" target="_blank">
            <div id="config-extra-info" class="icon-info"></div>
          </a>
          <br/>
          <div id="config-box-wrapper" class="table-wrapper">
            <form>
              <div id="config-box"></div>
                <div id="config-button-wrapper">
                  <button id="config-button"><?php echo $l->__("Run"); ?></button>
                  <img id="loading-gif" src="img/loading-small.gif">
                  <div id="circle-retstatus" class="icon-red-circle"></div>
                </div>
            </form>
            <textarea readonly id="details-box" class="outputbox" rows="12"></textarea>
          </div>
        </div>

        <div id="dashboard-wrapper">
          <h2 class="text-title"><?php echo $l->__("System Info"); ?></h2>
          <div id="dashboard-suggestions" class="table-wrapper"></div>
          <div id="dashboard-table" class="outputbox table-wrapper"></div>
          <div id="loading-info-gif"> <img src="img/loading-small.gif"> </div>
        </div>

        <div id="nc-config-wrapper" class="hidden">
          <h2 class="text-title"><?php echo $l->__("Nextcloud configuration"); ?></h2>
          <div id="nc-config-box" class="table-wrapper">
<?php
          $config = file_get_contents( '/var/www/nextcloud/config/config.php' );
          $config = str_replace( "\n", "<br>", $config );
           echo "$config";
?>
        </div>
        </div>
    </div>

  <div id="poweroff-dialog" class='dialog primary hidden'>
      <div id='poweroff-option_shutdown' class='button big-button'>
         <img class="wizard-btn" src="img/poweroff.svg">&nbsp;&nbsp;shut down
      </div>
      <div id='poweroff-option_reboot'   class='button big-button'>
         <img class="wizard-btn" src="img/reboot.svg">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;reboot&nbsp;&nbsp;&nbsp;
      </div>
  </div>

  <?php
    include('csrf.php');
    echo '<input type="hidden" id="csrf-token"      name="csrf-token"      value="' . getCSRFToken() . '"/>';
    echo '<input type="hidden" id="csrf-token-dash" name="csrf-token-dash" value="' . getCSRFToken() . '"/>';
  ?>
    <script src="minified.js"></script>
    <script src="ncp.js"></script>
</body>
</html>

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
