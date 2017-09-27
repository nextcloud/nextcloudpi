/*jslint browser: true*/
/*global $, jQuery, alert*/
$(document).ready(function(){
	// This must be first or it breaks
	$('#rootwizard').bootstrapWizard({onTabShow: function(tab, navigation, index){
		var $total = navigation.find('li').length;
		var $current = index+1;
		var $percent = ($current/$total) * 100;
		$('#rootwizard').find('.progress-bar').css({width:$percent+'%'});
	}});
	/* For some reason value="USBStick" didn't work in the <input> element */
	// document.getElementById('usb-label').value = 'USBStick';
	// document.getElementById('data-location').value = '/media/USBdrive/ncdata';
	document.getElementById('freedns-domain').value = 'cloud.ownyourbits.com';
	document.getElementById('freedns-hash').value = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJK1234567';
	document.getElementById('freedns-time').value = '10';
	document.getElementById('noip-user').value = '';
	document.getElementById('noip-password').value = '';
	document.getElementById('noip-domain').value = 'mycloud.ownyourbits.com';
	document.getElementById('noip-time').value = '10';

	// This is required or the tabs aren't styled
	$('#rootwizard').bootstrapWizard({'tabClass': 'nav nav-pills'}); 
	// Enable Automount step
	$('#enable-Automount').on('click', function() {
		$("#plug-usb").show(500);
		$('html, body').animate({
        scrollTop: $("#plug-usb").offset().top
    }, 2000);
		dataTable[0] = {
			automount: 'yes'
		};
		console.log(JSON.stringify(dataTable));
	});
	// Disable Automount step
	$('#disable-Automount').on('click', function() {
		$("#plug-usb").hide();
		$('#rootwizard').bootstrapWizard('next');
		dataTable[0] = {
			automount: 'no'
		};
		dataTable[1] = {
			plugUSB: 'no'
		};
		console.log(JSON.stringify(dataTable));
	});
	// Enable format-usb step
	$('#plugUSB').on('click', function() {
		$("#format-usb").show(500);
		$('html, body').animate({
        scrollTop: $("#format-usb").offset().top
    }, 2000);
		dataTable[1] = {
			plugUSB: 'yes'
		};
		console.log(JSON.stringify(dataTable));
	});
	// Enable nextcloud-data step
	$('#format-USB').on('click', function() {
		dataTable[2] = {
			format: 'yes',
		};
		$('#rootwizard').bootstrapWizard('next');
		console.log(JSON.stringify(dataTable));
	});
	// Enable nextcloud data tab on skip format.
	$('#skip-format-USB').on('click', function() {
		$("#nextcloud-data").show(500);
		$('html, body').animate({
			scrollTop: $("#nextcloud-data").offset().top
    }, 2000);
		dataTable[2] = {
			format: 'no',
		};
		$('#rootwizard').bootstrapWizard('next');
		console.log(JSON.stringify(dataTable));
	});
	// Move to next tab on port forward skip.
	$('#access-outside-no').on('click', function() {
		dataTable[4] = {
			accessOutside: 'no'
		};
		console.log(JSON.stringify(dataTable));
		$('#rootwizard').bootstrapWizard('next');
	});
	// Run test ports
	$('#test-ports-run').on('click', function() {
		// Run test ports 
		dataTable[5] = {
			testPorts: 'yes' // Enable fail2ban
		};
		console.log(JSON.stringify(dataTable));
	});
	// If test ports are ok, run this
	$('#test-ports-ok').on('click', function() {
		$("#port-forward").hide();
		$("#port-forward-not-ok").hide();
		dataTable[6] = {
			testPorts: 'ok'
		};
		dataTable[7] = {
			portForwardRun: 'no'
		}
		dataTable[8] = {
			portForward: 'ok-before'
		}
		console.log(JSON.stringify(dataTable));
		$('#rootwizard').bootstrapWizard('next');
	});
	// If test ports fail run this and move to next step
	$('#test-ports-continue').on('click', function() {
		$("#port-forward").show(500);
		$('html, body').animate({
        scrollTop: $("#port-forward").offset().top
    }, 2000);
		dataTable[6] = {
			testPorts: 'ok'
		};
		console.log(JSON.stringify(dataTable));
	});
	// Run port forwarding with UPnP step
	$('#port-forward-run').on('click', function() {
		// Run Port Forwarding and Test Port
		dataTable[7] = {
			portForwardRun: 'yes'
		};
		console.log(JSON.stringify(dataTable));
	});
	// If test after port forwarding is ok, run this
	$('#port-forward-ok').on('click', function() {
		$("#port-forward-not-ok").hide();
		dataTable[7] = {
			portForwardRun: 'yes'
		};
		dataTable[8] = {
			portForward: 'ok-after'
		}
		console.log(JSON.stringify(dataTable));
		$('#rootwizard').bootstrapWizard('next');
	});
	// If test after port forwarding is not ok, run this
	$('#port-forward-error').on('click', function() {
		$("#port-forward-not-ok").show(500);
		$('html, body').animate({
        scrollTop: $("#port-forward-not-ok").offset().top
    }, 2000);
		dataTable[8] = {
			portForward: 'not-ok'
		};
		console.log(JSON.stringify(dataTable));
	});
	// Enable DDNS step
	$('#ddns-yes').on('click', function() {
		$("#choose-ddns").show(500);
		$('html, body').animate({
        scrollTop: $("#choose-ddns").offset().top
    }, 2000);
		dataTable[9] = {
			ddns: 'yes'
		};
		console.log(JSON.stringify(dataTable));
	});
	// Skip DDNS setup
	$('#ddns-skip').on('click', function() {
		$("#choose-ddns").hide();
		$('#rootwizard').bootstrapWizard('next');
		dataTable[9] = {
			ddns: 'no'
		};
		console.log(JSON.stringify(dataTable));
	});
	// Show FreeDNS step
	$('#ddns-freedns').on('click', function() {
		$("#noip").hide();
		$("#freedns").show(500);
		$('html, body').animate({
        scrollTop: $("#freedns").offset().top
    }, 2000);

		dataTable[9] = {
			ddns: 'yes',
			service: 'freedns'
		};
		console.log(JSON.stringify(dataTable));
	});
	// Enable FreeDNS step
	$('#ddns-enable-freedns').on('click', function() {
		dataTable[9] = {
			ddns: 'yes',
			service: 'freedns',
			domain: $("freedns-domain").val(),
			updateHash: $("freedns-hash").val(),
			updateInterval: $("freedns-time").val(),
		};
		$('#rootwizard').bootstrapWizard('next');
		console.log(JSON.stringify(dataTable));
	});
	// Show noip step
	$('#ddns-noip').on('click', function() {
		$("#freedns").hide();
		$("#noip").show(500);
		$('html, body').animate({
        scrollTop: $("#onip").offset().top
    }, 2000);
		dataTable[9] = {
			ddns: 'yes',
			service: 'noip'
		};
		console.log(JSON.stringify(dataTable));
	});
	// Enable noip step
	$('#ddns-enable-noip').on('click', function() {
		dataTable[9] = {
			ddns: 'yes',
			service: 'noip',
			user: $("#noip-user").val(),
			password: $("#noip-password").val(),
			domain: $("noip-domain").val(),
			time: $("noip-time").val(),
		};
		$('#rootwizard').bootstrapWizard('next');
		console.log(JSON.stringify(dataTable));
	});
	
});

var dataTable = [];
console.log("hi");