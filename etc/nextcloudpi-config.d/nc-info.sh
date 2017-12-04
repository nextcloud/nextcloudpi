#!/bin/bash

# Print NCP sytem info
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh nc-diag.sh <IP> (<img>)
#
# See installer.sh instructions for details
# More at: https://ownyourbits.com
#

DESCRIPTION="Print NextCloudPi system info"

configure() 
{
  # info

  local OUT="$( ncp-diag )"
  echo "Gathering information..."
  echo "$OUT" | column -t -s'|'

  # suggestions

  DNSMASQ_ON="$( grep "^ACTIVE_=" /usr/local/etc/nextcloudpi-config.d/dnsmasq.sh | cut -d'=' -f2 )"
  
  grep -q "distribution|.*bian GNU/Linux 9" <<<"$OUT" || \
    echo -e "\nYou are using an unsupported distro release. Please upgrade to latest Debian/Raspbian"

  [[ $DNSMASQ_ON != "yes" ]] && \
    grep -q "NAT loopback|no" <<<"$OUT" && \
      echo -e "\nYou should enable dnsmasq to use your domain inside home"

  grep -q "certificates|none" <<<"$OUT" && \
    echo -e "\nYou should run Lets Encrypt for trusted encrypted access"

  grep -q "port check .*|closed" <<<"$OUT" && \
      echo -e "\nYou should open your ports for Lets Encrypt and external access"

  grep -q "USB devices|none" <<<"$OUT" || {
    grep -q "data in SD|yes" <<<"$OUT" && \
      echo -e "\nYou should use nc-datadir to move your files to your plugged in USB drive"

    grep -q "automount|no" <<<"$OUT" && \
      echo -e "\nYou should enable automount to uyyse your plugged in USB drive"
  }
  return 0
}

install() { :; }

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

