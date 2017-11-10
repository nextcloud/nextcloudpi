#!/bin/bash

# Perform a software update in NextCloudPi
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh build-devel.sh <IP> (<img>)
#
# See installer.sh instructions for details
#
# More at https://ownyourbits.com/
#

# this is a replica of ncp-update, but from devel branch
install() 
{
  # wait for other apt processes
  pgrep apt &>/dev/null && echo "waiting for apt processes to finish..." && \
  while :; do
    pgrep apt &>/dev/null || break
    sleep 1
  done
  rm -f /etc/apt/apt.conf.d/20nextcloudpi-upgrades

  echo -e "Downloading updates"
  rm -rf /tmp/ncp-update-tmp
  git clone --depth 20 -q -b devel https://github.com/nextcloud/nextcloudpi.git /tmp/ncp-update-tmp
  cd /tmp/ncp-update-tmp || return 1

  echo -e "Performing updates"
  ./update.sh

  VER=$( git describe --always --tags | grep -oP "v\d+\.\d+\.\d+" )
  grep -qP "v\d+\.\d+\.\d+" <<< $VER && {       # check format
    echo "$VER" > /usr/local/etc/ncp-version
    echo "$VER" > /var/run/.ncp-latest-version
  }

  cd / || return 1
  rm -rf /tmp/ncp-update-tmp

  echo -e "NextCloudPi updated to version $VER"
}

cleanup()   { :; }
configure() { :; }

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

