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
        ?>
	</head>
<body>
<div id="rootwizard">
	<ul id="ncp-nav">
		<li><a href="#tab1" data-toggle="tab">Welcome</a></li>
		<li><a href="#tab2" data-toggle="tab">USB Configuration</a></li>
		<li><a href="#tab3" data-toggle="tab">Port Forwarding</a></li>
		<li><a href="#tab4" data-toggle="tab">DDNS</a></li>
		<li><a href="#tab5" data-toggle="tab">Finish</a></li>
	</ul>
	<div id="bar" class="progress">
		<div class="progress-bar" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width: 0%;"></div>
	</div>
	<div class="tab-content">
		<!-- Tab 1 content - Welcome -->
		<div class="tab-pane" id="tab1">
			<div class="ncp-tab-pane">
				<h1>Welcome to NextCloudPi</h1>
                <img id="ncp-welcome-logo" src="img/ncp-logo.png">
				<p>This wizard will help you configure your personal cloud.</p>
			</div>
		</div>
		<!-- Tab 2 content - USB Configuration -->
		<div class="tab-pane" id="tab2">
			<div class="ncp-tab-pane">
				<!-- Enable Automount -->
				<p class="instructions"> Do you want to save Nextcloud data in a USB drive?</p>
				<div class="buttons-area">
					<input type="button" class="btn" id="enable-Automount" value="Yes" />
					<input type="button" class="btn" id="disable-Automount" value="No" />
				</div>
				<!-- Test mount -->
				<div class="ncp-hidden" id="plug-usb">
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
		<!-- Tab 3 content - Test ports - Port Forwarding -->
		<div class="tab-pane" id="tab3">
			<div class="ncp-tab-pane">
                  <p class="instructions">
                      To access from the outside, your need to forward ports 80 and 443 to your RPi IP address <br>
                      You can have NextCloudPi try to do this automatically for you<br>
                      To do it manually, you can access your router interface, normally at <a href="http://192.168.1.1" target="_blank">http://192.168.1.1</a><br>
                  </p>
                  <div class="buttons-area">
                      <input type="button" class="btn" id="port-forward-run"   value="Try to do it for me"/>
                      <input type="button" class="btn" id="port-forward-skip"  value="I will do it manually"/>
                  </div>
				</div>
				<!-- Throw error message when test after UPnP fails -->
				<div class="ncp-hidden" id="port-forward-not-ok">
					<p class="instructions" style="color: red">
						Couldn't configure port forwarding automatically. You must manually enable UPnP from your Router. After this, try again.
					</p>
				</div>	
			</div>
		<!-- Tab 4 content - DDNS -->
			<div class="tab-pane" id="tab4">
				<div class="ncp-tab-pane">
					<p class="instructions">
                        You need a DDNS provider in order to access from outside.<br>
                        You will get a domain URL, such as mycloud.ownyourbits.com.<br>
                        You need to create a free account with FreeDNS, DuckDNS or No-IP. <br>
                        If you don't know which one to chose just <a href="https://freedns.afraid.org/signup/?plan=starter" target="_blank">click here for FreeDNS</a> <br>
                        <br>
						Choose a client.
					<div class="buttons-area">
					    <input type="button" class="btn" id="ddns-freedns" value="FreeDNS"/>
					    <input type="button" class="btn" id="ddns-noip" value="No-IP"/>
					    <input type="button" class="btn" id="ddns-skip" value="Skip"/>
					</div>
					<!-- Configure FreeDNS -->
					<div class="ncp-hidden" id="freedns">
						<p class="instructions">
							Fill the input area for FreeDNS.
						</p>
						<div class="buttons-area">
							<form class="ddns-form">
								<p>Domain
									<input type="text" id="freedns-domain" placeholder="cloud.ownyourbits.com">
								</p>	
								<p>Update Hash
									<input type="text" id="freedns-hash" placeholder="abcdefghijklmnopqrstuvwxyzABCDEFGHIJK1234567">
								</p>
							</form>
							<input type="button" class="btn" id="ddns-enable-freedns" value="Enable FreeDNS"/>
						</div>
					</div>
					<!-- Configure No-IP -->	
					<div class="ncp-hidden" id="noip">
						<p class="instructions">
						Fill in the input area for No-IP.
						</p>
						<div class="buttons-area">
							<div class="ddns-form">
								<form>
									<p>User
									<input type="text" id="noip-user" placeholder="user@ownyourbits.com">
									</p>
									<p>Password
									<input type="text" id="noip-password" placeholder="secret">
									</p>
									<p>Domain
									<input type="text" id="noip-domain" placeholder="cloud.ownyourbits.com">
									</p>
								</form>
							</div>	
							<input type="button" class="btn" id="ddns-enable-noip" value="Enable No-IP"/>
						</div>
					</div>
				</div>
			</div>
			<!-- Tab 5 content - Finish -->
			<div class="tab-pane" id="tab5">
				<div class="ncp-tab-pane">
					<p class="instructions">
						NextCloudPi is ready!</p>

                      <div class="linkbox">
                        <a id='gotonextcloud' href="#"><img id="nextcloud" src="img/nc-logo.png"></a>
                        <br>go to your Nextcloud
                      </div>
                      <div class="linkbox">
                        <a href=".."><img id="ncp-web" src="img/ncp-logo.png"></a>
                        <br>go back to NextCloudPi web panel
                      </div>

				</div>		
			</div>
		</div>
		<!-- Navigation buttons -->
	<ul class="pager wizard" id="ncp-pager">
		<li class="previous first" style="display:none;"><a href="#">First</a></li>
		<li class="previous"><a href="#">Previous</a></li>
		<li class="next last" style="display:none;"><a href="#">Last</a></li>
		<li class="next"><a href="#">Next</a></li>
	</ul>
</div>

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
