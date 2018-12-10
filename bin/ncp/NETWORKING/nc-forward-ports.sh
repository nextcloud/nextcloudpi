#!/bin/bash

# Use uPnP to forward router ports for NextCloudPi
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at: https://ownyourbits.com
#


install()
{
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends miniupnpc
}

configure() 
{
  local IFACE=$( ip r | grep "default via" | awk '{ print $5 }' | head -1 )
  local IP=$( ip a show dev "$IFACE" | grep global | grep -oP '\d{1,3}(.\d{1,3}){3}' | head -1 )
  upnpc -d "$HTTPSPORT" TCP
  upnpc -d "$HTTPPORT"  TCP
  upnpc -a "$IP" 443 "$HTTPSPORT" TCP | tee >(cat - >&2) | grep -q "is redirected to internal" || \
    { echo -e "\nCould not forward ports automatically.\nDo it manually, or activate UPnP in your router and try again"; return 1; }
  upnpc -a "$IP" 80  "$HTTPPORT"  TCP | tee >(cat - >&2) | grep -q "is redirected to internal" || \
    { echo -e "\nCould not forward ports automatically.\nDo it manually, or activate UPnP in your router and try again"; return 1; }
}

# License
#
# This script is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This script is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this script; if not, write to the
# Free Software Foundation, Inc., 59 Temple Place, Suite 330,
# Boston, MA  02111-1307  USA

