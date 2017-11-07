<!DOCTYPE html>
<html>
	<head>
		<title>NextCloudPi Wizard</title>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<!-- Bootstrap -->
		<link href="bootstrap/css/bootstrap.min.css" rel="stylesheet">
		<link href="CSS/wizard.css" rel="stylesheet">
        <?php 
            session_start();

            // security headers
            header("Content-Security-Policy: default-src 'none'; script-src 'self'; connect-src 'self'; img-src 'self'; style-src 'self'; object-src 'self';");
            header("X-XSS-Protection: 1; mode=block");
            header("X-Content-Type-Options: nosniff");
            header("X-Robots-Tag: none");
            header("X-Permitted-Cross-Domain-Policies: none");
            header("X-Frame-Options: DENY");
            header("Cache-Control: max-age=15778463");
            ini_set('session.cookie_httponly', 1);
            if ( isset($_SERVER['HTTPS']) )
              ini_set('session.cookie_secure', 1); 
        ?>
        <link rel="icon" type="image/png" href="../img/favicon.png" />
	</head>
<body>
<div id="rootwizard">
	<ul id="ncp-nav">
		<li><a href="#tab1" data-toggle="tab">Welcome</a></li>
		<li><a href="#tab2" data-toggle="tab">USB Configuration</a></li>
		<li><a href="#tab3" data-toggle="tab">External access</a></li>
		<li><a href="#tab4" data-toggle="tab">Finish</a></li>
	</ul>
	<div id="bar" class="progress">
		<div class="progress-bar" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width: 0%;"></div>
	</div>
	<div class="tab-content">
		<!-- Tab 1 content - Welcome -->
		<div class="tab-pane" id="tab1">
			<div class="ncp-tab-pane">
				<h1>Welcome to NextCloudPi</h1>
                <img id="ncp-welcome-logo" src="img/ncp-logo.svg">
				<p>This wizard will help you configure your personal cloud.</p>
			</div>
		</div>
		<!-- Tab 2 content - USB Configuration -->
		<div class="tab-pane" id="tab2">
			<div class="ncp-tab-pane">
				<!-- Enable Automount -->
				<p class="instructions"> Do you want to save Nextcloud data in a USB drive?</p>
				<div class="buttons-area">
					<input type="button" class="btn" id="enable-automount" value="Yes" />
					<input type="button" class="btn" id="disable-automount" value="No" />
				</div>
				<!-- Test mount -->
				<div class="ncp-hidden" id="plug-usb-pane">
					<p class="instructions">Plug in the USB drive and hit continue.</p>
					<div class="buttons-area">
						<input type="button" class="btn" id="plugUSB" value="Continue"/>
					</div>
				</div>
				<!-- Format USB drive -->
				<div class="ncp-hidden" id="format-usb">
					<p class="instructions">
						If you want to prepare the USB drive to be used with NextCloudPi hit Format USB. Skip if already formated as ext4.
						<br>	
						<strong>Attention!</strong> This will format your USB drive as ext4 and <strong>will destroy any current data.</strong> 
					</p>
					<div class="buttons-area">
						<input type="button" class="btn" id="format-USB" value="Format USB"/>
						<input type="button" class="btn" id="skip-format-USB" value="Skip"/>
					</div>
				</div>
				<!-- Move datadir -->
				<div class="ncp-hidden" id="nc-datadir-pane">
					<div class="buttons-area">
						<input type="button" class="btn" id="nc-datadir" value="Move data to USB"/>
					</div>
				</div>
			</div>
		</div>
		<!-- Tab 3 content - External Access -->
		<div class="tab-pane" id="tab3">
			<div class="ncp-tab-pane">
				<!-- Enable external access -->
				<p class="instructions"> Do you want to access Nextcloud from outside your house?</p>
				<div class="buttons-area">
					<input type="button" class="btn" id="enable-external" value="Yes" />
					<input type="button" class="btn" id="skip-external" value="No" />
				</div>
				<div class="ncp-tab-pane ncp-hidden" id="forward-ports-pane">
                    <h3>Port forwarding</h3>
                    <p class="instructions">
                        To access from the outside, your need to forward ports 80 and 443 to your RPi IP address <br>
                        You can have NextCloudPi try to do this automatically for you<br>
                        To do it manually yourself, you must access your router interface, usually at <a href="http://192.168.1.1" target="_blank">http://192.168.1.1</a><br>
                    </p>
                    <div class="buttons-area">
                        <input type="button" class="btn" id="port-forward-run"    value="Try to do it for me"/>
                        <input type="button" class="btn" id="port-forward-manual" value="I will do it manually"/>
                    </div>
				</div>

				<div class="ncp-hidden" id="forward-ports-manual-pane">
                    <p class="instructions">
                        Click when you are finished
                    </p>
                    <div class="buttons-area">
                        <input type="button" class="btn" id="port-forward-done"  value="Continue"/>
                    </div>
				</div>
				<div class="ncp-tab-pane ncp-hidden" id="ddns-choose">
                    <h3>DDNS</h3>
                    <p class="instructions">
                        You need a DDNS provider in order to access from outside.<br>
                        You will get a domain URL, such as mycloud.ownyourbits.com.<br>
                        You need to create a free account with FreeDNS, DuckDNS or No-IP. <br>
                        If you don't know which one to choose just <a href="https://freedns.afraid.org/signup/?plan=starter" target="_blank">click here for FreeDNS</a> <br>
                        <br>
                        Choose a client.
                    <div class="buttons-area">
                        <input type="button" class="btn" id="ddns-freedns" value="FreeDNS"/>
                        <input type="button" class="btn" id="ddns-noip" value="No-IP"/>
                        <input type="button" class="btn" id="ddns-skip" value="Skip"/>
                    </div>
                </div>
                <!-- DDNS domain -->
                <div class="ncp-hidden" id="ddns-account">
                    <div class="buttons-area">
                        <p class="instructions"> Account details for DDNS service. </p>
                        <table>
                            <tr>
                                <td><label for="ddns-domain">Domain</label></td>
                                <td> <input type="text" id="ddns-domain" placeholder="cloud.ownyourbits.com"> </td>
                            </tr>
                        </table>
                    </div>

                    <!-- Configure FreeDNS -->
                    <div class="ncp-hidden" id="freedns">
                        <div class="buttons-area">
                            <form class="ddns-form">
                                <table>
                                    <tr>
                                        <td><label for="freedns-hash">Update Hash</label></td>
                                        <td><input type="text" id="freedns-hash" placeholder="abcdefghijklmnopqrstuvwxyzABCDEFGHIJK1234567"></td>
                                    </tr>
                                </table>
                                <div class="buttons-area">
                                    <button class="btn" id="ddns-enable-freedns">Finish</button>
                                </div>
                            </form>
                        </div>
                    </div>

                    <!-- Configure No-IP -->	
                    <div class="ncp-hidden" id="noip">
                        <div class="buttons-area">
                            <div class="ddns-form">
                                <form>
                                    <table>
                                        <tr>
                                            <td><label for="noip-user">User</label></td>
                                            <td><input type="text" id="noip-user" placeholder="user@ownyourbits.com"></td>
                                        </tr>
                                        <tr>
                                            <td><label for="noip-password">Password</label></td>
                                            <td><input type="text" id="noip-password" placeholder="secret"></td>
                                        </tr>
                                    </table>
                                    <div class="buttons-area">
                                        <button class="btn" id="ddns-enable-noip">Finish</button>
                                    </div>
                                </form>
                            </div>	
                        </div>
                    </div>
                </div>
			</div>
          </div>
          <!-- Tab 4 content - Finish -->
          <div class="tab-pane" id="tab4">
              <div class="ncp-tab-pane">
                  <p class="instructions"> NextCloudPi is ready!</p>

                  <div class="linkbox">
                    <a id='gotonextcloud' href="#"><img id="nextcloud" src="img/nc-logo.png"></a>
                    <br>go to your Nextcloud
                  </div>
                  <div class="linkbox">
                    <a href=".."><img id="ncp-web" src="img/ncp-logo.svg"></a>
                    <br>go back to NextCloudPi web panel
                  </div>

              </div>		
          </div>
      </div>

      <div class="expand">
          <div id="output-btn" class="menu-icon"></div>
      </div>

      <div id="output-wrapper" class="output-close ncp-hidden">
          <textarea readonly id="output-box" rows="25" cols="60"></textarea>
      </div>
      <div id="notifications"></div>

<?php
  include ('../csrf.php');
  echo '<input type="hidden" id="csrf-token" name="csrf-token" value="' . getCSRFToken() . '"/>';
?>

<script src="JS/jquery-latest.js"></script>
<script src="bootstrap/js/bootstrap.min.js"></script>
<script src="JS/jquery.bootstrap.wizard.js"></script>
<script src="JS/wizard.js"></script>
</body>
</html>
