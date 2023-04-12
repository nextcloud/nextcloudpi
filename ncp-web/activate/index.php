<?php
  // disallow once activated
  exec("a2query -s ncp-activation", $output, $ret);
  if ($ret != 0) {
    http_response_code(404);
    exit();
  }
  ini_set('session.cookie_httponly', 1);
  if (isset($_SERVER['HTTPS']))
    ini_set('session.cookie_secure', 1);
  session_start();

  // security headers
  header("Content-Security-Policy: default-src 'none'; script-src 'self'; connect-src 'self'; img-src 'self'; style-src 'self'; object-src 'self';");
  header("X-XSS-Protection: 1; mode=block");
  header("X-Content-Type-Options: nosniff");
  header("X-Robots-Tag: none");
  header("X-Permitted-Cross-Domain-Policies: none");
  header("X-Frame-Options: DENY");
  header("Cache-Control: no-cache");
  header('Pragma: no-cache');
  header('Expires: -1');
?>
<!DOCTYPE html>
<html class="ng-csp" data-placeholder-focus="false" lang="en">
<head>
  <meta http-equiv="content-type" content="text/html; charset=UTF-8">
  <meta charset="utf-8">
  <title> NextcloudPi Activation </title>
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="referrer" content="never">
  <meta name="viewport" content="width=device-width, minimum-scale=1.0, maximum-scale=1.0">
  <meta http-equiv="cache-control" content="no-cache">
  <meta http-equiv="pragma" content="no-cache">
  <link rel="icon" type="image/png" href="../img/favicon.png"/>
  <link rel="stylesheet" href="CSS.css">
</head>
<body id="body-login">
  <noscript>
    <div id="nojavascript">
    <div>
    This application requires JavaScript for correct operation. Please <a href="https://www.enable-javascript.com/" target="_blank" rel="noreferrer noopener">enable JavaScript</a> and reload the page.		</div>
    </div>
  </noscript>
  <div class="wrapper">
    <div class="v-align">
      <header role="banner">
        <div id="header">
          <img id="ncp-logo" src="../img/ncp-logo.svg">
<?php
    $nc_pwd  = rtrim( base64_encode( random_bytes(32) ) , '=' ); // remove last '='. Remove rtrim in the future
    $ncp_pwd = rtrim( base64_encode( random_bytes(32) ) , '=' ); // remove last '='. Remove rtrim in the future
    echo <<<HTML
          <h1>NextcloudPi Activation</h1>
          <p>Your NextcloudPi user     is </p><input readonly              type="text" size=32 value="ncp">
          <p>Your NextcloudPi password is </p><input readonly id="ncp-pwd" type="text" size=32 value="{$ncp_pwd}">&nbsp;&nbsp;<img id="cp-ncp" src="../img/clippy.svg"><span id="cp-ncp-ok"></span>
          <p>Save this password in order to access to the NextcloudPi web interface at https://nextcloudpi.local:4443</p>
          <p>This password can be changed using 'nc-passwd'</p>
<hr>
          <p>Your Nextcloud     user     is </p><input readonly              type="text" size=32 value="ncp">
          <p>Your Nextcloud     password is </p><input readonly id="nc-pwd"  type="text" size=32 value="{$nc_pwd}">&nbsp;&nbsp;<img id="cp-nc" src="../img/clippy.svg"><span id="cp-nc-ok"></span>
          <p>Save this password in order to access Nextcloud https://nextcloudpi.local</p>
          <p>This password can be changed from the Nextcloud user configuration</p>
<br>
          <p>
             <button type="button" id="print-pwd"   > Print    </button>
             <button type="button" id="activate-ncp"> Activate </button>
          </p>
<br>
          <img id="loading-gif" src="../img/loading-small.gif">
          <div id="error-box"></div>
HTML;
?>
        </div>
      </header>
    </div>
  </div>
  <footer role="contentinfo">
  <p class="info">
  <a href="https://nextcloudpi.com" target="_blank" rel="noreferrer noopener">NextcloudPi</a> – Keep your data close</p>
  </footer>
  <?php
    include('../csrf.php');
    echo '<input type="hidden" id="csrf-token" name="csrf-token" value="' . getCSRFToken() . '"/>';
  ?>
  <script src="../js/minified.js"></script>
  <script src="JS.js"></script>
</body>
</html>
