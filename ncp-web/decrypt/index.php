<?php
  // disallow once unlocked
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
  <title> Unlock NextcloudPi </title>
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
    echo <<<HTML
          <h1>NextcloudPi</h1>
          <p>Encrypted instance</p>

          <div id="decrypt-config-box" class="content-box table-wrapper">
          <form>
            <table><tbody>
              <tr>
                <td>
                  <input type="password" id="encryption-pass" name="Password" class="directory" default="" placeholder="password" size="40">
                  &nbsp;
                  <img class="pwd-btn" title="show password" src="../img/toggle-white.svg">
                </td>
              </tr>     
            </tbody></table>

            <div class="config-button-wrapper">
              <button id="decrypt-btn" type="submit" class="config-button">Decrypt</button>
              <img id="loading-gif" src="../img/loading-small.gif">
              <div class="circle-retstatus icon-red-circle"></div>
              <div id="error-box"></div>
           </div>
        </form>
        </div>
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
