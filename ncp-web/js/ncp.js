///
// NextCloudPi Web Panel javascript library
//
// Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
// GPL licensed (see end of file) * Use at your own risk!
//
// More at https://ownyourbits.com/2017/02/13/nextcloud-ready-raspberry-pi-image/
///

var MINI = require('minified');
var $ = MINI.$, $$ = MINI.$$, EE = MINI.EE;
var selectedID = null;
var lock       = false;

// URL based navigation
window.onpopstate = function(event) {
  var ncp_app = location.search.split('=')[1];
  if (ncp_app == 'config')
    switch_to_section('nc-config');
  else if (ncp_app == 'dashboard')
    switch_to_section('dashboard');
  else
    app_clicked($('#' + ncp_app));
};

function errorMsg()
{ 
  $('#config-box').fill( "Something went wrong. Try refreshing the page" ); 
}

function switch_to_section(section)
{
  $( '#config-wrapper > div'    ).hide();
  $( '#dashboard-wrapper'       ).hide();
  $( '#nc-config-wrapper'       ).hide();
  $( '#' + section + '-wrapper' ).show();
  $( '#app-navigation ul' ).set('-active');
  selectedID = null;
}

// slide menu
var slide_menu_enabled = false;

function open_menu()
{
  if ( !slide_menu_enabled ) return;
  if ( $('#app-navigation').get('$width') != '250px' )
  {
    $('#overlay').show();
    $('#overlay').on('|click', close_menu );
    $('#app-navigation').animate( {$width: '250px'}, 150 );
  }
}

function close_menu()
{
  if ( !slide_menu_enabled ) return;
  if ( $('#app-navigation').get('$width') == '250px' )
  {
    $('#app-navigation').animate( {$width: '0px'}, 150 );
    $('#overlay').hide();
    $.off( close_menu );
  }
}

function hide_overlay(e) { $('#overlay').hide() }

function close_menu_on_click_out(e) { close_menu(); }

function enable_slide_menu()
{
  if ( slide_menu_enabled ) return;
  $( '#app-navigation' ).set( { $width: '0px' } );
  $( '#app-navigation' ).set( { $position: 'absolute' } );
  $( '#app-navigation-toggle' ).on('click', open_menu );
  $( '#app-content' ).on('|click', close_menu_on_click_out );
  slide_menu_enabled = true;
}

function disable_slide_menu()
{
  if ( !slide_menu_enabled ) return;
  $.off( open_menu );
  $.off( close_menu );
  $.off( close_menu_on_click_out );
  $( '#app-navigation' ).set( { $width: '250px' } );
  $( '#app-navigation' ).set( { $position: 'unset' } );
  $('#overlay').hide();
  slide_menu_enabled = false;
}

function set_sidebar_click_handlers()
{
  // Show selected option configuration box
  $( 'ul' , '#app-navigation' ).on('click', function(e)
  {
    if ( selectedID == this.get( '.id' ) ) // already selected
      return;

    if ( lock ) return;

    if ( window.innerWidth <= 768 )
      close_menu();

    $( '#app-navigation ul' ).set('-active');
    app_clicked(this);
    history.pushState(null, selectedID, "?app=" + selectedID);
  });
}

function print_dashboard()
{
  $.request('post', 'ncp-launcher.php', { action: 'info',
                                          csrf_token: $( '#csrf-token-ui' ).get( '.value' ) }).then(

    function success( result )
    {
      var ret = $.parseJSON( result );
      if ( ret.token )
        $('#csrf-token-ui').set( { value: ret.token } );
      $('#loading-info-gif').hide();
      $('#dashboard-table').ht( ret.table );
      $('#dashboard-suggestions').ht( ret.suggestions );
      reload_sidebar();
    } ).error( errorMsg );
}

function reload_sidebar()
{
  // request
  $.request('post', 'ncp-launcher.php', { action:'sidebar', 
    csrf_token: $( '#csrf-token-ui' ).get( '.value' ) }).then( 
      function success( result ) 
      {
        var ret = $.parseJSON( result );
        if ( ret.token )
          $('#csrf-token-ui').set( { value: ret.token } );
        if ( ret.ret && ret.ret == '0' ) {
          $('#ncp-options').ht( ret.output );
          set_sidebar_click_handlers();
        }
      }).error( errorMsg );
}

function app_clicked(item)
{
  $('.details-box').hide();
  $('.circle-retstatus').hide();
  $('#' + selectedID + '-config-box').hide();
  switch_to_section('config');
  selectedID = item.get('.id');
  item.set('+active');
  $('#' + selectedID + '-config-box').show();
}

$(function() 
{
  // Event source to receive process output in real time
  if (!!window.EventSource)
    var source = new EventSource('ncp-output.php');
  else
    $('#config-box-title').fill( "Browser not supported" );

  $('#poweroff-dialog').hide();
  $('#overlay').hide();

  source.addEventListener('message', function(e) 
    {
      if ( e.origin != 'https://' + window.location.hostname + ':4443') 
      {
        $('.details-box').fill( "Invalid origin" ); 
        return;
      }

      var box = $$('.details-box');
      $('.details-box').ht( box.innerHTML + e.data + '<br>' );
      box.scrollTop = box.scrollHeight;
    }, false);

  set_sidebar_click_handlers();

  // Launch selected script
  $( '.config-button' ).on('click', function(e)
  {
    lock = true;
    $('.details-box').hide( '' );
    $('.config-button').set('@disabled',true);
    $('.loading-gif').set( { $display: 'inline' } );

    // create configuration object
    var cfg = {};
    $( 'input' , '#' + selectedID + '-config-box' ).each( function(item){
      if( item.getAttribute('type') == 'checkbox' )
        item.value = item.checked ? 'yes' : 'no';

      cfg[item.name] = item.value;
    } );

    $( 'select', '#config-box' ).each( function(item) {
      var select = {
        'id': item.name,
        'value': []
      };
      $("#" + item.id + '>option').each(function(option) {
        select.value.push(option.selected ? "_" + option.value + "_" : "" + option.value);
      });
      cfg[select.id] = select.value;
    });


    // reset box
    $('.details-box').fill();
    $('.details-box').show();
    $('.details-box').set( {$height: '0vh'} );
    $('.details-box').animate( {$height: '50vh'}, 150 );
    $('.circle-retstatus').hide();

    $( 'input' , '#config-box-wrapper' ).set('@disabled',true);

    // request
    $.request('post', 'ncp-launcher.php', { action:'launch', 
                                            ref   : selectedID,
                                            config: $.toJSON(cfg),
                                            csrf_token: $( '#csrf-token' ).get( '.value' ) }).then(
      function success( result ) 
      {
        var ret = $.parseJSON( result );
        if ( ret.token )
          $('#csrf-token').set( { value: ret.token } );
        if ( ret.ret )                           // means that the process was launched
        {
          if ( ret.ret == '0' ) 
          {
            if( ret.ref && ret.ref == 'nc-update' )
              window.location.reload( true );
            reload_sidebar();
            $('.circle-retstatus').set( '+icon-green-circle' );
          }
          else 
            $('.circle-retstatus').set( '-icon-green-circle' );
          $('.circle-retstatus').show();
        }
        else                                     // print error from server instead
          $('.details-box').fill(ret.output);
        $( 'input' , '#config-box-wrapper' ).set('@disabled', null);
        $('.config-button').set('@disabled',null);
        $('.loading-gif').hide();
        lock = false;
      }).error( errorMsg );
  });

  // Show password button
  $( '.pwd-btn' ).on('click', function(e)
    {
      var input = this.trav('previousSibling', 1);
      if ( input.get('.type') == 'password' )
        input.set('.type', 'text');
      else if ( input.get('.type') == 'text' )
        input.set('.type', 'password');
    });

  // Reset to defaults button
  $( '.default-btn' ).on('click', function(e)
    {
      var input = this.trav('previousSibling', 1);
      input.set('.value', input.get('@default'));
      input.trigger('change');
    });

  // Path fields
  $( '.path' ).on('|keydown', function(e)
    {
      var span = this.up().select('span', true);
      span.fill();
    }
  );

  // Path fields
  $( '.path' ).on('change', function(e)
    {
      var span = this.up().select('span', true);
      // request
      $.request('post', 'ncp-launcher.php', { action:'path-exists',
                                              value: this.get('.value'),
                                              csrf_token: $( '#csrf-token-cfg' ).get( '.value' ) }).then(
          function success( result )
          {
            var ret = $.parseJSON( result );
            if ( ret.token )
              $('#csrf-token-cfg').set( { value: ret.token } );
            if ( ret.ret && ret.ret == '0' )                        // means that the process was launched
            {
              span.fill("path exists")
              span.set('-error-field');
              span.set('+ok-field');
            }
            else
            {
              span.fill("path doesn't exist")
              span.set('-ok-field');
              span.set('+error-field');
            }
          }
      ).error( errorMsg )
    } );

  // Update notification
  $( '#notification' ).on('click', function(e)
  {
    if ( lock ) return;
    lock = true;
    
    $( '#app-navigation ul' ).set('-active');

    app_clicked( $('#nc-update') );

    //clear details box
    $('.details-box').hide( '' );
  } );

  // slide menu
  if ( window.innerWidth <= 768 ) 
    enable_slide_menu();

  window.addEventListener('resize', function(){ 
    if ( window.innerWidth <= 768 ) 
      enable_slide_menu();
    else
      disable_slide_menu();
  } );

  // Power-off button
  function hide_poweroff_dialog(ev)
  {
    $('#poweroff-dialog').hide();
    $('#overlay').hide();
    $('#overlay').off('click');
  }
  function poweroff_event_handler(e)
  {
    $('#overlay').show();
    $('#poweroff-dialog').show();
    $('#overlay').on('click', hide_poweroff_dialog );
  }
  $( '#poweroff' ).on('click', poweroff_event_handler );

  $( '#poweroff-option_shutdown' ).on('click', function(e)
  {
    $('#poweroff-dialog').hide();
    $('#overlay').hide();

    // request
    $.request('post', 'ncp-launcher.php', { action:'poweroff', 
                                            csrf_token: $( '#csrf-token' ).get( '.value' ) }).then( 
      function success( result ) 
      {
        switch_to_section( 'nc-config' );
        $.off( poweroff_event_handler );
        $('#nc-config-wrapper').ht('<h2 class="text-title">Shutting down...<h2>');
      }).error( errorMsg );
  } );

  $( '#poweroff-option_reboot' ).on('click', function(e)
  {
    $('#poweroff-dialog').hide();
    $('#overlay').hide();
    // request
    $.request('post', 'ncp-launcher.php', { action:'reboot', 
                                            csrf_token: $( '#csrf-token' ).get( '.value' ) }).then( 
      function success( result ) 
      {
        switch_to_section( 'nc-config' );
        $.off( poweroff_event_handler );
        $('#nc-config-wrapper').ht('<h2 class="text-title">Rebooting...<h2>');
      }).error( errorMsg );
  } );

  // close notification icon
  $( '.icon-close' ).on('click', function(e)
  {
    $( '#notification' ).hide();
  } );
 
  // close first run box
  $( '.first-run-close' ).on('click', function(e)
  {
    $( '#first-run-wizard' ).hide();
  } );
  $( '#first-run-wizard' ).on('|click', function(e)
  {
    if( e.target.id == 'first-run-wizard' )
      $( '#first-run-wizard' ).hide();
  } );

  // click to nextcloud button
  $('#nextcloud-btn').set( '@href', window.location.protocol + '//' + window.location.hostname );

  // dashboard button
  $( '#dashboard-btn' ).on('click', function(e)
  {
    if ( lock ) return;
    close_menu();
    switch_to_section( 'dashboard' );
    history.pushState(null, selectedID, "?app=dashboard");
  } );

  // config button
  $( '#config-btn' ).on('click', function(e)
  {
    if ( lock ) return;
    close_menu();
    switch_to_section( 'nc-config' );
    history.pushState(null, selectedID, "?app=config");
  } );

  // language selection
  var langold = $( '#language-selection' ).get( '.value' );
  $( '#language-selection' ).on( 'change', function(e)
    {
      if( '[new]' == this.get( '.value' ) )
      {
        this.set( '.value', langold );
        var url = 'https://github.com/nextcloud/nextcloudpi/wiki/Add-a-new-language-to-ncp-web';
        if ( !window.open( url, '_blank' ) ) // try to open in a new tab first
          window.location.href = url;
        return;
      }
      // request
      $.request('post', 'ncp-launcher.php', { action:'cfg-ui',
                                              value: this.get( '.value' ),
                                              csrf_token: $( '#csrf-token-cfg' ).get( '.value' ) }).then(
        function success( result )
        {
          var ret = $.parseJSON( result );
          if ( ret.token )
            $('#csrf-token-cfg').set( { value: ret.token } );
          if ( ret.ret && ret.ret == '0' )                        // means that the process was launched
            window.location.reload( true );
          else
            this.set( '.value', langold );
        }
    ).error( errorMsg )
  } );

  // load dashboard info
  print_dashboard();
} );

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
