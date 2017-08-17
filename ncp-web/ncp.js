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

$(function() 
{
  // Show selected option configuration box
  $( 'li' , '#app-navigation' ).on('click', function(e)
  {
    if ( confLock ) return;
    confLock = true;

    $( '#' + selectedID ).set('-active');
    this.set( '+active' );

    var that = this;
    $.request('post', 'ncp-launcher.php', { action:'cfgreq', 
                                            ref:this.get('.id') ,
                                            csrf_token: $( '#csrf-token' ).get( '.value' ) }).then( 
      function success( result ) 
      {
        selectedID = that.get('.id');
        var ret = $.parseJSON( result );
        if ( ret.token )
          $('#csrf-token').set( { value: ret.token } );
        $('#config-box').ht( ret.output ); 
        $('#config-box-title').fill( $( 'input' , '#' + selectedID ).get( '.value' ) ); 
        $('#config-box-wrapper').show();
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
        $('#details-box').fill(ret.output);
        $('#details-box').show();
        $('#config-button').set('@disabled',null);
        $('#loading-gif').hide();
        confLock = false;
      }).error( errorMsg );
  });

  // Power-off button
  $( '#poweroff' ).on('click', function(e)
  {
    // request
    $.request('post', 'ncp-launcher.php', { action:'poweroff', 
                                            csrf_token: $( '#csrf-token' ).get( '.value' ) }).then( 
      function success( result ) 
      {
        $('#config-box-title').fill( "Shutting down..." ); 
      }).error( errorMsg );
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
