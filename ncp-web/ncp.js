///
// NextcloudPi Web Panel javascript library
//
// Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
// GPL licensed (see end of file) * Use at your own risk!
//
// More at https://ownyourbits.com/2017/02/13/nextcloud-ready-raspberry-pi-image/
///

var MINI = require('minified');
var $ = MINI.$, $$ = MINI.$$, EE = MINI.EE;
var selectedID = null;
var confLock   = false;

function errorMsg()
{ 
  $('#config-box').fill( "Something went wrong. Try refreshing the page" ); 
}

function switch_to_section( name )
{
  $( '#config-wrapper'    ).hide();
  $( '#dashboard-wrapper' ).hide();
  $( '#nc-config-wrapper' ).hide();
  $( '#' + name + '-wrapper' ).show();
  $( '#' + selectedID ).set('-active');
  selectedID = null;
}

function cfgreqReceive( result )
{
  var ret = $.parseJSON( result );
  if ( ret.token )
    $('#csrf-token').set( { value: ret.token } );

  $('#details-box'      ).hide();
  $('#circle-retstatus').hide();
  $('#config-box').ht( ret.output );
  $('#config-box-title'    ).fill( $( '#' + selectedID + '-desc' ).get( '.value' ) ); 
  $('#config-box-info-txt' ).fill( $( '#' + selectedID + '-info' ).get( '.value' ) ); 
  switch_to_section( 'config' );
  $('#config-box-wrapper').show();
  $('#config-extra-info').set( { $display: 'inline-block' } );
  $('#config-extra-info').up().set( '@href', 'https://github.com/nextcloud/nextcloudpi/wiki/Configuration-Reference#' + selectedID );
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
        $('#details-box').fill( "Invalid origin" ); 
        return;
      }

      var textarea = $('#details-box');
      textarea.fill( textarea.text() + e.data + '\n' );
      textarea[0].scrollTop = textarea[0].scrollHeight;
    }, false);

  // Show selected option configuration box
  $( 'li' , '#app-navigation' ).on('click', function(e)
  {
    if ( selectedID == this.get( '.id' ) ) // already selected
      return;

    if ( confLock ) return;
    confLock = true;

    if ( window.innerWidth <= 768 )
      close_menu();

    $( '#' + selectedID ).set('-active');
    var that = this;
    $.request('post', 'ncp-launcher.php', { action:'cfgreq', 
                                            ref:this.get('.id') ,
                                            csrf_token: $( '#csrf-token' ).get( '.value' ) }).then( 
      function success( result ) 
      {
        cfgreqReceive( result );
        selectedID = that.get('.id');
        that.set( '+active' );
        confLock = false;
      }).error( errorMsg );
  });

  // Launch selected script
  $( '#config-button' ).on('click', function(e)
  {
    confLock = true;
    $('#details-box').hide( '' );
    $('#config-button').set('@disabled',true);
    $('#loading-gif').set( { $display: 'inline' } );

    // create configuration object
    var cfg = {};
    $( 'input' , '#config-box' ).each( function(item){
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
    $('#details-box').fill();
    $('#details-box').show();
    $('#details-box').set( {$height: '0px'} );
    $('#details-box').animate( {$height: '500px'}, 150 );
    $('#circle-retstatus').hide();

    $( 'input' , '#config-box-wrapper' ).set('@disabled',true);

    // request
    $.request('post', 'ncp-launcher.php', { action:'launch', 
                                            ref:selectedID ,
                                            config: $.toJSON(cfg),
                                            csrf_token: $( '#csrf-token' ).get( '.value' ) }).then( 
      function success( result ) 
      {
        var ret = $.parseJSON( result );
        if ( ret.token )
          $('#csrf-token').set( { value: ret.token } );
        if ( ret.ret )                           // means that the process was launched
        {
          if ( ret.ret == '0' ) $('#circle-retstatus').set( '+icon-green-circle' );
          else                  $('#circle-retstatus').set( '-icon-green-circle' );
          $('#circle-retstatus').show();
        }
        else                                     // print error from server instead
          $('#details-box').fill(ret.output);
        $( 'input' , '#config-box-wrapper' ).set('@disabled', null);
        $('#config-button').set('@disabled',null);
        $('#loading-gif').hide();
        confLock = false;
      }).error( errorMsg );
  });

  // Update notification
  $( '#notification' ).on('click', function(e)
  {
    if ( confLock ) return;
    confLock = true;
    
    $( '#' + selectedID ).set('-active');

    // request
    $.request('post', 'ncp-launcher.php', { action:'cfgreq', 
                                            ref:'nc-update' ,
                                            csrf_token: $( '#csrf-token' ).get( '.value' ) }).then( 
      function success( result ) 
      {
        selectedID = 'nc-update';
        $( '#nc-update' ).set( '+active' );

        cfgreqReceive( result );

        confLock = false;
      }
      ).error( errorMsg );

    //clear details box
    $('#details-box').hide( '' );
  } );

  // slide menu
  var slide_menu_enabled = false;

  function hide_overlay(e) { $('#overlay').hide() }

  function open_menu()
  {
    if ( $('#app-navigation').get('$width') != '250px' )
    {
      $('#overlay').show();
      $('#overlay').on('|click', close_menu );
      $('#app-navigation').animate( {$width: '250px'}, 150 );
    }
  }

  function close_menu()
  {
    if ( $('#app-navigation').get('$width') == '250px' )
    {
      $('#app-navigation').animate( {$width: '0px'}, 150 );
      $('#overlay').hide();
      $.off( close_menu );
    }
  }

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
        $('#config-box-wrapper').hide();
        $.off( poweroff_event_handler );
        $('#config-box-title').fill( "Shutting down..." ); 
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
        $('#config-box-wrapper').hide();
        $.off( poweroff_event_handler );
        $('#config-box-title').fill( "Rebooting..." ); 
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
  $( '#first-run-wizard' ).on('click', function(e)
  {
    if( e.target.id == 'first-run-wizard' )
      $( '#first-run-wizard' ).hide();
  } );

  // click to nextcloud button
  $('#nextcloud-btn').set( '@href', window.location.protocol + '//' + window.location.hostname );

  // load dashboard info
  $.request('post', 'ncp-launcher.php', { action: 'info',
                                          csrf_token: $( '#csrf-token-dash' ).get( '.value' ) }).then(

    function success( result )
    {
      var ret = $.parseJSON( result );
      if ( ret.token )
        $('#csrf-token').set( { value: ret.token } );
      $('#loading-info-gif').hide();
      $('#dashboard-table').ht( ret.table );
      $('#dashboard-suggestions').ht( ret.suggestions );
    } ).error( errorMsg );

  // dashboard button
  $( '#dashboard-btn' ).on('click', function(e)
  {
    switch_to_section( 'dashboard' );
  } );

  // config button
  $( '#config-btn' ).on('click', function(e)
  {
    switch_to_section( 'nc-config' );
  } );
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
