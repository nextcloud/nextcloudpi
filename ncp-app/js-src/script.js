// open the NCP web panel

var url = window.location.protocol + '//' + window.location.hostname + ':4443';

if ( !window.open( url, '_blank' ) ) // try to open in a new tab first
  window.location.href = url;
