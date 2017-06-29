#!/bin/bash

# Use uPnP to forward router ports for NextCloudPi
# Tested with 2017-03-02-raspbian-jessie-lite.img
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh nc-forward-ports.sh <IP> (<img>)
#
# See installer.sh instructions for details
# More at: https://ownyourbits.com
#

PORT_=443
DESCRIPTION="Set port forwarding to access from outside (UPnP)"

show_info()
{
  whiptail --yesno \
    --backtitle "NextCloudPi configuration" \
    --title "Instructions for UPnP Port Forwarding" \
"For NextCloudPi to be able to setup your ports, UPnP must be activated
in your router. Activate it now on your router admin webpage.

** UPnP is considered a security risk **

Don't forget to disable it afterwards" \
      20 90
}

install()
{
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends miniupnpc
}

configure() 
{
  local IFACE=$( ip r | grep "default via" | awk '{ print $5 }' )
  local IP=$( ip a | grep "global $IFACE" | grep -oP '\d{1,3}(.\d{1,3}){3}' | head -1 )
  upnpc -d $PORT_ TCP
  upnpc -a $IP 443 $PORT_ TCP
}

cleanup()
{
  apt-get autoremove -y
  apt-get clean
  rm /var/lib/apt/lists/* -r
  rm -f /home/pi/.bash_history
  systemctl disable ssh
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

