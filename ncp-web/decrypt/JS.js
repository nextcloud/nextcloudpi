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

function errorMsg()
{ 
  $('#error-box').fill("Something went wrong. Try refreshing the page"); 
}

function decrypt_ok_cb(result) 
{
  var ret = $.parseJSON(result);
  $('#loading-gif').hide();
  if ( ret.token )
    $('#csrf-token').set( { value: ret.token } );
  if ( ret.ret == '0' ) {
    $('#error-box').fill("OK"); 
      var url = window.location.protocol + '//' + window.location.hostname;
      window.location.replace( url );
  } else {
    $('#error-box').fill("Password error"); 
    $('#decrypt-btn').show();
  }
}

function decrypt()
{
  // request
  $.request('post', '../ncp-launcher.php', { action: 'launch',
                                             ref   : 'nc-encrypt', 
                                             config: '{ "ACTIVE": "yes", "PASSWORD":"' + $('#encryption-pass').get('.value') + '" }',
                                             csrf_token: $('#csrf-token').get('.value') } 
  ).then(decrypt_ok_cb).error(errorMsg);
}

// Show password button
$( '.pwd-btn' ).on('click', function(e)
  {
    var input = this.trav('previousSibling', 1);
    if ( input.get('.type') == 'password' )
      input.set('.type', 'text');
    else if ( input.get('.type') == 'text' )
      input.set('.type', 'password');
  });

$(function() 
{
  $('#decrypt-btn').on('click', function(e)
  {
    $('#decrypt-btn').hide();
    $('#loading-gif').set( { $display: 'inline' } );
    decrypt();
  } );

  $$('#encryption-pass').focus();
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
