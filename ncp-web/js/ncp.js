///
// NextcloudPi Web Panel javascript library
//
// Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
// GPL licensed (see end of file) * Use at your own risk!
//
// More at https://nextcloudpi.com
///

var MINI = require('minified');
var $ = MINI.$, $$ = MINI.$$, EE = MINI.EE;
var selectedID   = null;
var ncp_app_list = null;
var search_box   = null;
var lock         = false;

// URL based navigation
// TODO unify repeating code
window.onpopstate = function(event) {
  selectedID = location.search.split('=')[1];
  if (selectedID == 'backups')
    switch_to_section('backups');
  else if (selectedID == 'config')
    switch_to_section('nc-config');
  else if (selectedID == 'dashboard')
    switch_to_section('dashboard');
  else if (selectedID == 'logs')
    switch_to_section('logs');
  else
    click_app($('#' + selectedID));
};

function errorMsg()
{
  $('#app-content').fill( "Something went wrong. Try refreshing the page" );
}

function switch_to_section(section)
{
  // TODO unify repeating code
  $( '#config-wrapper > div'    ).hide();
  $( '#dashboard-wrapper'       ).hide();
  $( '#logs-wrapper'            ).hide();
  $( '#nc-config-wrapper'       ).hide();
  $( '#backups-wrapper'         ).hide();
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
    click_app(this);
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
      print_backups();
    } ).error( errorMsg );
}

function del_bkp(button)
{
    var tr = button.up().up();
    var path = tr.get('.id');
    $.request('post', 'ncp-launcher.php', { action:'del-bkp',
                                            value: path,
                                            csrf_token: $( '#csrf-token' ).get( '.value' ) }).then(
      function success( result )
      {
        var ret = $.parseJSON( result );
        if ( ret.token )
          $('#csrf-token').set( { value: ret.token } );
        if ( ret.ret && ret.ret == '0' )                        // means that the process was launched
          tr.remove();
        else
          console.log('failed removing ' + path);
       }
  ).error( errorMsg )
}

function restore_bkp(button)
{
  var tr = button.up().up();
  var path = tr.get('.id');
  click_app($('#nc-restore'));
  history.pushState(null, selectedID, "?app=" + selectedID);
  $('#nc-restore-BACKUPFILE').set({ value: path });
  $('#nc-restore-config-button').trigger('click');
}

function restore_snap(button)
{
  var tr = button.up().up();
  var path = tr.get('.id');
  click_app($('#nc-restore-snapshot'));
  history.pushState(null, selectedID, "?app=" + selectedID);
  $('#nc-restore-snapshot-SNAPSHOT').set({ value: path });
  $('#nc-restore-snapshot-config-button').trigger('click');
}

function del_snap(button)
{
    var tr = button.up().up();
    var path = tr.get('.id');
    $.request('post', 'ncp-launcher.php', { action:'del-snap',
                                            value: path,
                                            csrf_token: $('#csrf-token').get('.value') }).then(
      function success( result )
      {
        var ret = $.parseJSON( result );
        if ( ret.token )
          $('#csrf-token').set( { value: ret.token } );
        if ( ret.ret && ret.ret == '0' )                        // means that the process was launched
          tr.remove();
        else
          console.log('failed removing ' + path);
       }
  ).error( errorMsg )
}

function restore_upload(button)
{
    var file = $$('#restore-upload').files[0];
    if (!file) return;
    var upload_token = $('#csrf-token').get('.value');
    var form_data = new FormData();
    form_data.append('backup', file);
    form_data.append('csrf_token', upload_token);
    $.request('post', 'upload.php', form_data).then(
      function success( result )
      {
        var ret = $.parseJSON( result );
        if ( ret.token )
          $('#csrf-token').set( { value: ret.token } );
        if ( ret.ret && ret.ret == '0' )                        // means that the process was launched
        {
          click_app($('#nc-restore'));
          history.pushState(null, selectedID, "?app=" + selectedID);
          $('#nc-restore-BACKUPFILE').set({ value: '/tmp/' + upload_token.replace('/', '') + file.name });
          $('#nc-restore-config-button').trigger('click');
        }
        else
          console.log('error uploading ' + file);
      }
  ).error( errorMsg )
}

clicked_dialog_button = null;
clicked_dialog_action = null;

function dialog_action(button)
{
  if ( clicked_dialog_action && clicked_dialog_button)
    clicked_dialog_action(clicked_dialog_button);
}

function refresh_dl_token()
{
  $.request('post', 'ncp-launcher.php', { action:'next-dl',
    csrf_token: $( '#csrf-token' ).get( '.value' ) }).then(
      function success( result )
      {
        var ret = $.parseJSON( result );
        if ( ret.token )
          $('#csrf-token').set( { value: ret.token } );
        if ( ret.token_dl )
          $('#csrf-token-dl').set( { value: ret.token_dl } );
      }
    ).error( errorMsg )
}

// backups
function set_backup_handlers()
{
  $( '.download-bkp' ).on('click', function(e)
    {
      var tr = this.up().up();
      var path = tr.get('.id');
      var token_dl = $('#csrf-token-dl').get('.value');
      window.location.replace('download.php?bkp=' + encodeURIComponent(path) + '&token=' + encodeURIComponent(token_dl));
      refresh_dl_token();
    });
  $( '.delete-bkp' ).on('click', function(e)
    {
      $('#confirmation-dialog').show();
      clicked_dialog_action = del_bkp;
      clicked_dialog_button = this;
    });
  $( '.restore-bkp' ).on('click', function(e)
    {
      $('#confirmation-dialog').show();
      clicked_dialog_action = restore_bkp;
      clicked_dialog_button = this;
    });
  $( '#restore-upload-btn' ).on('click', function(e)
    {
      var file = $$('#restore-upload').files[0];
      if (!file) return;
      $('#confirmation-dialog').show();
      clicked_dialog_action = restore_upload;
      clicked_dialog_button = this;
    });
  $( '.restore-snap' ).on('click', function(e)
    {
      $('#confirmation-dialog').show();
      clicked_dialog_action = restore_snap;
      clicked_dialog_button = this;
    });
  $( '.delete-snap' ).on('click', function(e)
    {
      $('#confirmation-dialog').show();
      clicked_dialog_action = del_snap;
      clicked_dialog_button = this;
    });
}

function print_backups()
{
  // request
  $.request('post', 'ncp-launcher.php', { action:'backups',
                                          csrf_token: $('#csrf-token-ui').get('.value') }
  ).then(
      function success( result )
      {
        var ret = $.parseJSON( result );
        if (ret.token)
          $('#csrf-token-ui').set({ value: ret.token });
        if (ret.ret && ret.ret == '0') {
          $('#loading-backups-gif').hide();
          $('#backups-content').ht(ret.output);
          set_backup_handlers();
          reload_sidebar();
        }
      }).error( errorMsg );
}

function reload_sidebar()
{
  // request
  $.request('post', 'ncp-launcher.php', { action:'sidebar',
                                          csrf_token: $('#csrf-token-ui').get('.value') }
  ).then(
      function success( result )
      {
        var ret = $.parseJSON( result );
        if ( ret.token )
          $('#csrf-token-ui').set( { value: ret.token } );
        if ( ret.ret && ret.ret == '0' ) {
          $('#ncp-options').ht( ret.output );
          set_sidebar_click_handlers();
          if (selectedID && $$('#config-wrapper').style.display == 'block')
            select_app($('#' + selectedID));

          ncp_app_list = $('.ncp-app-list-item');
          filter_apps();
        }
      }).error( errorMsg );
}

function filter_apps(e)
{
  var search_box_val = search_box.value.toLowerCase();

  if (e && e.key === 'Enter')
  {
    if (search_box.value.length == 0 ) return;
    var match = ncp_app_list.find(function(app) { if (app.id.toLowerCase().indexOf(search_box_val) !== -1) return app; });
    if (!match) return;
    click_app($('#' + match.id));
    ncp_app_list.show();
    search_box.value = '';
    var input = $$('#' + match.id + '-config-box input');
    input.focus();
    if( input.getAttribute('type') != 'checkbox' )
      input.selectionStart = input.selectionEnd = input.value.length;
    $('#search-box').animate( {$width: '0px'}, 150 ).then(function() { $('#search-box').hide(); });
    history.pushState(null, selectedID, "?app=" + selectedID);
    return;
  }

  ncp_app_list.hide();
  ncp_app_list.each( function(app){
      if (app.id.toLowerCase().indexOf(search_box_val) !== -1)
        app.style.display = 'block';
    }
  );
}

function click_app(item)
{
  $('.details-box').hide();
  $('.circle-retstatus').hide();
  select_app(item);
}

function select_app(item)
{
  $('#' + selectedID + '-config-box').hide();
  switch_to_section('config');
  selectedID = item.get('.id');
  item.set('+active');
  $('#' + selectedID + '-config-box').show();
}

$(function()
{
  // parse selected app from URL
  if (location.search)
    selectedID = location.search.split('=')[1];

  // scroll down logs box by default
  var logs_box_l = $('#logs-details-box');
  var logs_box = logs_box_l[0];
  logs_box.scrollTop = logs_box.scrollHeight;
  //$('#logs-details-box').scrollTop = $('#logs-details-box').scrollHeight;

  // Event source to receive process output in real time
  if (!!window.EventSource)
    var source = new EventSource('ncp-output.php');
  else
    $('#config-box-title').fill( "Browser not supported" );

  $('#poweroff-dialog').hide();
  $('#overlay').hide();

  function escapeHTML(str) {
    return str.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
  }

  source.addEventListener('message', function(e)
    {
      if ( e.origin != 'https://' + window.location.hostname + ':4443')
      {
        $('.details-box').fill( "Invalid origin" );
        return;
      }

      if (!selectedID) return;
      var box_l = $('#' + selectedID + '-details-box');
      var box   = box_l[0];
      box_l.ht( box.innerHTML + escapeHTML(e.data) + '<br>' );
      box.scrollTop = box.scrollHeight;
    }, false);

  set_sidebar_click_handlers();

  // Launch selected ncp_app
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

      var shortID = item.id.replace(selectedID + '-', '');
      cfg[shortID] = item.value;
    } );

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
            if (ret.ref)
            {
              if (ret.ref == 'nc-update')
                window.location.reload( true );
              else if(ret.ref == 'nc-backup')
                print_backups();
              if(ret.ref != 'nc-restore' && ret.ref != 'nc-backup') // FIXME PHP is reloaded asynchronously after nc-restore
                reload_sidebar();
            }

            $('.circle-retstatus').set('+icon-green-circle');
          }
          else
            $('.circle-retstatus').set('-icon-green-circle');
        }
        else                                     // print error from server instead
        {
          $('.details-box').fill(ret.output);
          $('.circle-retstatus').set('-icon-green-circle');
        }
        $( 'input' , '#config-box-wrapper' ).set('@disabled', null);
        $('.config-button').set('@disabled',null);
        $('.loading-gif').hide();
        $('.circle-retstatus').show();
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
  $('.directory').on('change', function(e)
    {
      var span = this.up().select('span', true);
      var path = this.get('.value');

      // request
      $.request('post', 'ncp-launcher.php', { action:'path-exists',
                                              value: path,
                                              csrf_token: $('#csrf-token-cfg').get('.value') }).then(
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
  $('.file').on('change', function(e)
    {
      function dirname(path) { return path.replace(/\\/g,'/').replace(/\/[^\/]*$/, ''); }

      var span = this.up().select('span', true);
      var path = dirname(this.get('.value'));

      // request
      $.request('post', 'ncp-launcher.php', { action:'path-exists',
                                              value: path,
                                              csrf_token: $('#csrf-token-cfg').get('.value') }).then(
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

    click_app( $('#nc-update') );

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

  // dialog confirmation
  $( '#confirmation-dialog-ok' ).on('click', function(e)
  {
    $( '#confirmation-dialog' ).hide();
    dialog_action();
  } );
  $( '.confirmation-dialog-close' ).on('click', function(e)
  {
    $( '#confirmation-dialog' ).hide();
  } );
  $( '#confirmation-dialog' ).on('|click', function(e)
  {
    if( e.target.id == 'confirmation-dialog' )
      $( '#confirmation-dialog' ).hide();
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

  // TODO unify repeating code
  // config button
  $( '#config-btn' ).on('click', function(e)
  {
    if ( lock ) return;
    close_menu();
    switch_to_section( 'nc-config' );
    history.pushState(null, selectedID, "?app=config");
  } );

  // backups button
  $( '#backups-btn' ).on('click', function(e)
  {
    if ( lock ) return;
    close_menu();
    switch_to_section( 'backups' );
    history.pushState(null, selectedID, "?app=backups");
  } );

  // logs button
  $( '#logs-btn' ).on('click', function(e)
  {
    if ( lock ) return;
    close_menu();
    switch_to_section( 'logs' );
    history.pushState(null, selectedID, "?app=logs");
  } );

  // log download button
  $( '#log-download-btn' ).on('click', function(e)
    {
      var token_dl = $('#csrf-token-dl').get('.value');
      var token = $('#csrf-token').get('.value');
      window.location.replace('download_logs.php?token=' + encodeURIComponent(token_dl));
      refresh_dl_token();
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
            this.set('.value', langold);
        }
    ).error( errorMsg )
  } );

  // search box
  search_box = $$('#search-box');
  ncp_app_list = $('.ncp-app-list-item');
  $('#search-box').on('|keyup', filter_apps );
  $('#search-box').on('|blur', function(e) {
      $('#search-box').animate( {$width: '0px'}, 150 ).then(function() { $('#search-box').hide(); });
  } );
  search_box.value = '';
  search_box.focus();
  $('.icon-search').on('click', function(e) {

    $('#search-box').show();
    search_box.focus();
    $('#search-box').animate( {$width: '130px'}, 150 );
  });

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
