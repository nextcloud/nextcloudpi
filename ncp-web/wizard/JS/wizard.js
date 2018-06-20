/*jslint browser: true*/
/*global $, jQuery, alert*/
$(document).ready(function(){

    var in_docker = document.getElementById( 'in-docker' );

    function addNotification( txt, tclass )
    {
      // limit to 9 notifications
      if ( $('#notifications').children().length > 8 )
        $('#notifications').children().last().remove();

      $('#notifications').prepend( '<div class="notification ' + tclass + '">' + txt + '</div>' );
    }
  
    function logOutput( txt )
    {
      var textarea = $('#output-box');
      textarea.val( textarea.val() + txt );
      textarea[0].scrollTop = textarea[0].scrollHeight;
    }

    function showLog()
    {
      $('#output-wrapper').show();
      var textarea = $('#output-box');
      textarea[0].scrollTop = textarea[0].scrollHeight;
      textarea.animate({ width: "40em" });
      $('#overlay').show();
    }

    // launch an request for launch action to the backend
    function launch_action( action /* string */, args /* object */, callback /* callback */ )
    {
      $('input').prop('disabled', true);
      $('button').prop('disabled', true);
      addNotification( action, 'gray-bg' ) ;

      $.post('../ncp-launcher.php',
        { action:'launch', 
          ref: action,
          config: JSON.stringify( args ),
          csrf_token: document.getElementById( 'csrf-token' ).value
        } 
      ).fail( errorMsg ).done( callback );
    }

    function nextOnSuccess( data, nextfunc, failfunc )
    {
      $('input').prop('disabled', false);
      $('button').prop('disabled', false);

      var res = JSON.parse( data );

      // save next single use token
      if ( res.token )
        $('#csrf-token').val( res.token );

      // remove gray (loading) notification
      $('#notifications').children().first().remove();

      // continue if ok
      var msg = res.ref || res.output || 'error';
      if ( res.ret && res.ret == 0 )
      {
        addNotification( msg, 'green-bg' );
        nextfunc();
      }
      else
      {
        addNotification( msg, 'orange-bg' );
        showLog();
        failfunc && failfunc();
      }
    }

    function nextTabOnSuccess( data )
    {
      nextOnSuccess( data, function(){ $('#rootwizard').bootstrapWizard('next') } );
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

    function post_ddns_hook( data )
    {
      nextOnSuccess( data, function(){
        launch_action( 'nc-autoupdate-ncp', { "ACTIVE":"yes" },

        function( data ){
          nextOnSuccess( data, function(){
            launch_action( 'dnsmasq', { "ACTIVE":"yes", "DOMAIN":$("#ddns-domain").val() },

        // keep this last, because it restarts the httpd server
        function( data ){
          nextOnSuccess( data, function(){
            launch_action( 'letsencrypt', { "DOMAIN":$("#ddns-domain").val() },

        nextTabOnSuccess

      ) } ) }
      ) } ) }
      ) } )
    }
    // Event source to receive process output in real time
    if (!!window.EventSource)
      var source = new EventSource('../ncp-output.php');
    else
      $('#config-box-title').val( "Browser not supported" ); 

    source.addEventListener('message', function(e) 
      {
        if ( e.origin != 'https://' + window.location.hostname + ':4443') 
        {
          $('#output-box').val( "Invalid origin" ); 
          return;
        }

        logOutput( e.data + '\n' );
      }, false);

    // start wizard clicking logo
    $('#ncp-welcome-logo ').on('click', function(){ $('#rootwizard').bootstrapWizard('next'); } );

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
	$('#enable-automount').on('click', function() {
        show_with_animation( 'plug-usb-pane' );
	});

	// Disable Automount step
	$('#disable-automount').on('click', function() {
		$("#plug-usb-pane").hide();
		$('#rootwizard').bootstrapWizard('next');
	});

	// Enable format-usb step
	$('#plugUSB').on('click', function() {
      launch_action( 'nc-automount',
        {"ACTIVE":"yes"}, 
        function ( data ){ 
          nextOnSuccess( data, function(){ show_with_animation( 'format-usb' ); } );
        }
      );
	});

	// Enable nextcloud-data step
	$('#format-USB').on('click', function(){
      launch_action( 'nc-format-USB',
        {"LABEL":"myCloudDrive"}, 
        function ( data ){
          nextOnSuccess( data, function(){ show_with_animation( 'nc-datadir-pane' ); } );
        }
      );
	});

	// Enable nextcloud data tab on skip format.
	$('#skip-format-USB').on('click', function(){
      show_with_animation( 'nc-datadir-pane' );
	});

	// Launch nc-datadir
	$('#nc-datadir').on('click', function() {
      launch_action( 'nc-datadir', {"DATADIR":"/media/USBdrive/ncdata"}, nextTabOnSuccess );
	});

	// Enable external access step
	$('#enable-external').on('click', function(){
      if ( !in_docker )
        launch_action( 'fail2ban',
          { "ACTIVE":"yes" }, 
          function ( data ){
            nextOnSuccess( data, function(){ show_with_animation( 'forward-ports-pane' ) } );
          }
        );
      else
        show_with_animation( 'forward-ports-pane' );
	});

	// Skip external access step
	$('#skip-external').on('click', function(){
      $('#forward-ports-manual-pane').hide();
      $('#forward-ports-pane'       ).hide();
      $('#ddns-choose'              ).hide();
      $("#ddns-account"             ).hide();
      $("#noip"                     ).hide();
      $("#freedns"                  ).hide();
      $('#rootwizard').bootstrapWizard('next');
	});

	// Run port forwarding with UPnP step
	$('#port-forward-run').on('click', function(){
		// Run Port Forwarding and Test Port
        launch_action( 'nc-forward-ports',
          {"HTTPSPORT":"443","HTTPPORT":"80"}, 
          function ( data ){
            nextOnSuccess( data, function(){ show_with_animation( 'ddns-choose' ) } );
          }
        );
	});

	// Manual port forwarding
	$('#port-forward-manual').on('click', function() {
        show_with_animation( 'forward-ports-manual-pane' );
	});

	// Manual port forwarding done
	$('#port-forward-done').on('click', function() {
        show_with_animation( 'ddns-choose' );
	});

	// Skip DDNS setup
	$('#ddns-skip').on('click', function(){
		$("#domain" ).hide();
		$("#noip"   ).hide();
		$("#freedns").hide();
		$('#rootwizard').bootstrapWizard('next');
	});

	// Show FreeDNS step
	$('#ddns-freedns').on('click', function(){
		$("#noip"   ).hide();
		$("#freedns").show();
        show_with_animation( 'ddns-account' );
	});

	// Enable FreeDNS step
	$('#ddns-enable-freedns').on('click', function(){
        launch_action( 'freeDNS', 
          {
            "ACTIVE":"yes",
            "DOMAIN":     $("#ddns-domain" ).val(),
            "UPDATEHASH": $("#freedns-hash").val(),
            "UPDATEINTERVAL": "30"
          },
          post_ddns_hook
        );
        // prevent scroll up
        return false;
	});

	// Show noip step
	$('#ddns-noip').on('click', function(){
		$("#noip"   ).show();
		$("#freedns").hide();
        show_with_animation( 'ddns-account' );
	});

	// Enable noip step
	$('#ddns-enable-noip').on('click', function(){
          launch_action( 'no-ip', 
          {
            "ACTIVE":"yes",
            "DOMAIN": $("#ddns-domain"  ).val(),
            "USER":   $("#noip-user"    ).val(),
            "PASS":   $("#noip-password").val(),
          },
          post_ddns_hook
        );
        // prevent scroll up
        return false;
      }
    );

    // show log output
	$('#output-btn').on('click', function(){
      showLog();
    } );

    // close log output
	$('.output-close').on('click', function(e){
      if( e.target.id == 'output-wrapper' )
      {
        $('#output-box').animate(
          { width: "0em" },
          { complete: function() {
              $('#output-wrapper').hide();
              $('#overlay').hide();
            }
          } );
      }
    } );

    // make sure log box starts empty
    $('#output-box').val('');

    // click to nextcloud button
    $('#gotonextcloud').attr('href', window.location.protocol + '//' + window.location.hostname );
});
