<?php
///
// Dispatcher of SSE events with the contents of the NCP log
//
// Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
// GPL licensed (see end of file) * Use at your own risk!
//
// More at https://ownyourbits.com/2017/02/13/nextcloud-ready-raspberry-pi-image/
///

header('Content-Type: text/event-stream; charset=utf-8');
header('Cache-Control: no-cache'); // recommended to prevent caching of event data.


/**
 * Constructs the SSE data format and flushes that data to the client.
 * ( from html5rocks.com )
 *
 * @param string $id Timestamp/id of this connection.
 * @param string $msg Line of text that should be transmitted.
 */
function sendMsg($id, $msg) 
{
  echo "id: $id"    . PHP_EOL;
  echo "data: $msg" . PHP_EOL;
  echo PHP_EOL;
  ob_flush();
  flush();
}

/**
 * Pings the client-browser to force detection of closed socket
 */
function pingClient()
{
  echo ' ';
  ob_flush();
  flush();
}

/**
 * Imitates 'tail --follow' functionality, and sends lines as SSE events
 * , while pinging browser to detect closed tab.
 * ( based on stack overflow )
 */
function follow($file)
{
  $size = 0;
  while (true) 
  {
    clearstatcache();
    $currentSize = filesize($file);
    if ($size == $currentSize) 
    {
      usleep(200000); // 0.2s
      // if the user refreshes the tab >5 times, it won't load because it doesn't detect closed socket 
      // , and all workers are in use
      pingClient();   
      continue;
    }

    $fh = fopen($file, "r");
    fseek($fh, $size);

    while ($line = fgets($fh)) 
      sendMsg( 'output' , $line );

    fclose($fh);
    $size = $currentSize;
  }
}

session_write_close();
echo str_pad('',1024*1024*4); // make sure the browser buffer becomes full
follow( '/run/ncp.log' );

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
?>
