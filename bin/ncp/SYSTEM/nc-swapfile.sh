#!/bin/bash

# Data dir configuration script for NextcloudPi
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at https://ownyourbits.com/
#


is_active()
{
  local DIR=$( swapon -s | sed -n 2p | awk '{ print $1 }' )
  [[ "$DIR" != "" ]] && [[ "$DIR" != "/var/swap" ]]
}

configure()
{
  local ORIG="$( swapon | tail -1 | awk '{ print $1 }' )"
  local DSTDIR="$(dirname "$SWAPFILE")"
  [[ "$ORIG" == "$SWAPFILE" ]] && { echo "nothing to do";                    return 0; }
  [[ -d "$SWAPFILE"         ]] && { echo "$SWAPFILE is a directory. Abort"; return 1; }
  [[ -d "$DSTDIR"            ]] || { echo "$DSTDIR Doesn't exist. Abort";     return 1; }

  [[ "$( stat -fc%T "$DSTDIR" )" == "btrfs" ]] && {
    echo "BTRFS doesn't support swapfiles. You can still use nc-zram"
    return 1
  }

  [[ $( stat -fc%d / ) == $( stat -fc%d "$DSTDIR" ) ]] && \
    echo -e "INFO: moving swapfile to another place in the same SD card\nIf you want to use an external mount, make sure it is properly set up"

  sed -i "s|#\?CONF_SWAPFILE=.*|CONF_SWAPFILE=$SWAPFILE|" /etc/dphys-swapfile
  sed -i "s|#\?CONF_SWAPSIZE=.*|CONF_SWAPSIZE=$SWAPSIZE|" /etc/dphys-swapfile
  grep -q vm.swappiness /etc/sysctl.conf || echo "vm.swappiness = 10" >> /etc/sysctl.conf && sysctl --load &>/dev/null

  dphys-swapfile setup && dphys-swapfile swapon && {
    [[ -f "$ORIG" ]] && swapoff "$ORIG" && rm -f "$ORIG"
    echo "swapfile moved successfully"
    return 0
  }

  echo "moving swapfile failed"
  return 1
}

install()
{
  if [[ "$(stat -fc%T /var)" != "btrfs" ]]; then
    apt_install dphys-swapfile
  fi
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

