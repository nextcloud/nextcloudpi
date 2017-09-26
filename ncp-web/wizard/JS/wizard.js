/*jslint browser: true*/
/*global $, jQuery, alert*/
$(document).ready(function(){

    // launch an request for launch action to the backend
    function launch_action( action /* string */, args /* object */, next /* callback */ )
    {
      $('input').prop('disabled', true);
      $.post('../ncp-launcher.php',
        { action:'launch', 
          ref: action,
          config: JSON.stringify( args ),
          csrf_token: document.getElementById( 'csrf-token' ).value
        } 
      ).fail( errorMsg ).done( next );
    }

    function nextTabOnSuccess( data )
    { 
      $('input').prop('disabled', false);
      var res = JSON.parse( data );
      if ( res.ret && res.ret == 0 )
        $('#rootwizard').bootstrapWizard('next');
      else
        alert( 'error ' + res.output );

      // save next single use token
      if ( res.token )
        $('#csrf-token').val( res.token );
    }

    function show_with_animation( elemid )
    {
      $('#' + elemid).show(500);
      $('html, body').animate({
        scrollTop: $('#' + elemid).offset().top
      }, 2000);
    }

    // Show error on failed AJAX call
    function errorMsg( data )
    { 
      alert('There was an error with the request'); 
    }

	// This must be first or it breaks
	$('#rootwizard').bootstrapWizard({onTabShow: function(tab, navigation, index){
		var $total = navigation.find('li').length - 1;
		var $current = index;
		var $percent = ($current/$total) * 100;
		$('#rootwizard').find('.progress-bar').css({width:$percent+'%'});
	}});

	// This is required or the tabs aren't styled
	$('#rootwizard').bootstrapWizard({'tabClass': 'nav nav-pills'}); 
	// Enable Automount step
	$('#enable-Automount').on('click', function() {
        show_with_animation( 'plug-usb' );
		dataTable[0] = {
			automount: 'yes'
		};
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
	});
	// Enable format-usb step
	$('#plugUSB').on('click', function() {
		dataTable[1] = {
			plugUSB: 'yes'
		};

        launch_action( 'nc-automount', {"ACTIVE":"yes"}, 
          function ( data )
          { 
            $('input').prop('disabled', false);
            var res = JSON.parse( data );
            if ( res.ret && res.ret == 0 )         // action ran ok
              show_with_animation( 'format-usb' );
            else                                   // action failed
              alert( 'error: ' + res.output );

            // save next single use token
            if ( res.token )
              $('#csrf-token').val( res.token );
          }
        );

	});
	// Enable nextcloud-data step
	$('#format-USB').on('click', function() {
		dataTable[2] = {
			format: 'yes',
		};

        launch_action( 'nc-format-USB', {"LABEL":"myCloudDrive"}, 
          function ( data )
          { 
            $('input').prop('disabled', false);
            var res = JSON.parse( data );
            if ( res.ret && res.ret == 0 )         // action ran ok
              show_with_animation( 'nc-datadir-pane' );
            else                                   // action failed
              alert( 'error: ' + res.output );

            // save next single use token
            if ( res.token )
              $('#csrf-token').val( res.token );
          }
        );
	});

	// Enable nextcloud data tab on skip format.
	$('#skip-format-USB').on('click', function() {
        show_with_animation( 'nc-datadir-pane' );
		dataTable[2] = {
			format: 'no',
		};
	});

	// Launch nc-datadir
	$('#nc-datadir').on('click', function() {
		dataTable[2] = {
			format: 'no',
		};
        launch_action( 'nc-datadir', {"DATADIR":"/media/myCloudDrive/ncdata"}, nextTabOnSuccess );
	});

	// Run port forwarding with UPnP step
	$('#port-forward-run').on('click', function() {
		// Run Port Forwarding and Test Port
		dataTable[7] = {
			portForwardRun: 'yes'
		};
      
        launch_action( 'nc-forward-ports', {"HTTPSPORT":"443","HTTPPORT":"80"}, nextTabOnSuccess );
	});

	// Skip port forwarding
	$('#port-forward-skip').on('click', function() {
		$("#port-forward-not-ok").hide();
		dataTable[7] = {
			portForwardRun: 'no'
		};
		$('#rootwizard').bootstrapWizard('next');
	});

	// If test after port forwarding is not ok, run this
	$('#port-forward-error').on('click', function() {
        show_with_animation( 'port-forward-not-ok' );
		dataTable[8] = {
			portForward: 'not-ok'
		};
	});
	// Skip DDNS setup
	$('#ddns-skip').on('click', function() {
		$("#choose-ddns").hide();
		$('#rootwizard').bootstrapWizard('next');
		dataTable[9] = {
			ddns: 'no'
		};
	});
	// Show FreeDNS step
	$('#ddns-freedns').on('click', function() {
		$("#noip").hide();
        show_with_animation( 'freedns' );

		dataTable[9] = {
			ddns: 'yes',
			service: 'freedns'
		};
	});
	// Enable FreeDNS step
	$('#ddns-enable-freedns').on('click', function() {
		dataTable[9] = {
			ddns: 'yes',
			service: 'freedns',
			domain: $("freedns-domain").val(),
			updateHash: $("freedns-hash").val(),
		};

        launch_action( 'freeDNS', 
          {
            "ACTIVE":"yes",
            "UPDATEHASH": $("freedns-hash").val(),
            "DOMAIN": $("freedns-domain").val(),
            "UPDATEINTERVAL": "30"
          },
          nextTabOnSuccess
        );
	});
	// Show noip step
	$('#ddns-noip').on('click', function() {
		$("#freedns").hide();
        show_with_animation( 'noip' );

		dataTable[9] = {
			ddns: 'yes',
			service: 'noip'
		};
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

        launch_action( 'no-ip', 
          {
            "ACTIVE":"yes",
            "USER": $("#noip-user").val(),
            "PASS": $("#noip-password").val(),
            "DOMAIN": $("noip-domain").val(),
            "TIME": "30"
          },
          nextTabOnSuccess
        );
	});

    // click to nextcloud button
    $('#gotonextcloud').attr('href', window.location.protocol + '//' + window.location.hostname );
});

var dataTable = [];
