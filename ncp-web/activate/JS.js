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
  $('#error-box').fill( "Something went wrong. Try refreshing the page" ); 
}

function launch_nc_passwd()
{
  // request
  $.request('post', '../ncp-launcher.php', { action: 'launch',
                                             ref   : 'nc-passwd', 
                                             config: '{ "PASSWORD":"' + $('#ncp-pwd').get('.value') + '",'
                                                     + '"CONFIRM" :"' + $('#ncp-pwd').get('.value') + '"}',
                                             csrf_token: $( '#csrf-token' ).get( '.value' ) }).then(

    function success( result )
    {
      var ret = $.parseJSON( result );
      if ( ret.ret == '0' )
      {
        setTimeout( function(){ 
          $('#loading-gif').hide();
          $('#error-box').fill( "ACTIVATION SUCCESSFUL" ); 
          var url = window.location.protocol + '//' + window.location.hostname + ':4443';
          if ( !window.open( url, '_blank' ) ) // try to open in a new tab first
            window.location.replace( url );
        }, 2500 );
      } else {
        $('#error-box').fill( "nc-passwd error" ); 
      }
  } ).error( errorMsg );
}

$(function() 
{
  // print info page
  $( '#print-pwd' ).on( 'click', function(e) { window.print(); } );

  // copy to clipboard
  $( '#cp-ncp' ).on( 'click', function(e)
    {
      var input = document.getElementById('ncp-pwd');
      input.focus();
      input.select();
      var res =document.execCommand( 'copy' );
      $('#cp-ncp-ok').fill( res ? "✓" : "✘" );
      input.selectionStart = input.selectionEnd;
    } );

  // copy to clipboard
  $( '#cp-nc' ).on( 'click', function(e)
    {
      var input = document.getElementById('nc-pwd');
      input.focus();
      input.select();
      var res =document.execCommand( 'copy' );
      $('#cp-nc-ok').fill( res ? "✓" : "✘" );
      input.selectionStart = input.selectionEnd;
    } );

  // activate NextCloudPi
  $( '#activate-ncp' ).on( 'click', function(e)
  {
    $( '#activate-ncp' ).hide();
    $( '#print-pwd'    ).hide();
    $('#loading-gif').set( { $display: 'inline' } );

    // request
    $.request('post', '../ncp-launcher.php', { action: 'launch',
                                               ref   : 'nc-admin', 
                                               config: '{ "PASSWORD":"' + $('#nc-pwd').get('.value') + '",'
                                                       + '"CONFIRM" :"' + $('#nc-pwd').get('.value') + '",'
                                                       + '"USER"    : "ncp" }',
                                               csrf_token: $( '#csrf-token' ).get( '.value' ) }).then(
      function success( result ) 
      {
        var ret = $.parseJSON( result );
        if ( ret.ret == '0' ) {
          if ( ret.token )
            $('#csrf-token').set( { value: ret.token } );
          launch_nc_passwd();
        } else {
          $('#error-box').fill( "nc-admin error" ); 
        }
      } ).error( errorMsg );
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
