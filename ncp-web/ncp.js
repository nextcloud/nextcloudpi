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

function cfgreqReceive( result )
{
  var ret = $.parseJSON( result );
  if ( ret.token )
    $('#csrf-token').set( { value: ret.token } );
  $('#circle-retstatus').hide();
  $('#config-box').ht( ret.output );
  $('#config-box-title').fill( $( '#' + selectedID + '-desc' ).get( '.value' ) ); 
  $('#config-box-info' ).fill( $( '#' + selectedID + '-info' ).get( '.value' ) ); 
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

    $( '#' + selectedID ).set('-active');
    var that = this;
    $.request('post', 'ncp-launcher.php', { action:'cfgreq', 
                                            ref:this.get('.id') ,
                                            csrf_token: $( '#csrf-token' ).get( '.value' ) }).then( 
      function success( result ) 
      {
        selectedID = that.get('.id');
        that.set( '+active' );

        cfgreqReceive( result );

        confLock = false;
      }).error( errorMsg );

    //clear details box
    $('#details-box').hide( '' );
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

    // reset box
    $('#details-box').fill();
    $('#details-box').show();
    $('#circle-retstatus').hide();

    $( 'input' , '#config-box-wrapper' ).set('@disabled',true);

    // request
    $.request('post', 'ncp-launcher.php', { action:'launch', 
                                            ref:selectedID ,
                                            config: $.toJSON(cfg) ,
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

  // Power-off button
  function poweroff_event_handler(e)
  {
    //e.preventBubble = true;
    $('#overlay').show();
    $('#poweroff-dialog').show();
    $('#overlay').on('click', function(ev)
    {
       $('#poweroff-dialog').hide();
       $('#overlay').hide();
       $('#overlay').off('click');
    });
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

  // Wizard button
  $( '.wizard-btn' ).on('click', function(e)
  {
    window.location = 'wizard';
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
});

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
