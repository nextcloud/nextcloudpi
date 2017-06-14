#!/bin/bash

# Perform a software update in NextCloudPi
# Tested with 2017-03-02-raspbian-jessie-lite.img
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh test-devel.sh <IP> (<img>)
#
# See installer.sh instructions for details
#
# More at https://ownyourbits.com/
#

# this is a replica of ncp-update, but from devel branch
install() 
{
  echo -e "Downloading updates"
  rm -rf /tmp/ncp-update-tmp
  git clone -q -b devel https://github.com/nextcloud/nextcloudpi.git /tmp/ncp-update-tmp
  cd /tmp/ncp-update-tmp

  echo -e "Performing updates"
  ./update.sh

  VER=$( git describe --always --tags | grep -oP "v\d+\.\d+\.\d+" )
  grep -qP "v\d+\.\d+\.\d+" <<< $VER && {       # check format
    echo $VER > /usr/local/etc/ncp-version
    echo $VER > /var/run/.ncp-latest-version
  }

  cd /
  rm -rf /tmp/ncp-update-tmp

  echo -e "NextCloudPi updated to version \e[1m$VER\e[0m"
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

