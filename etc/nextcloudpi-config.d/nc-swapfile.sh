#!/bin/bash

# Data dir configuration script for NextCloudPi
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh nc-swapfile.sh <IP> (<img>)
#
# See installer.sh instructions for details
#
# More at https://ownyourbits.com/
#

SWAPFILE_=/media/USBdrive/swap
SWAPSIZE_=1024
DESCRIPTION="Move and resize your swapfile. Recommended to move to a permanent USB drive"

is_active()
{
  local DIR=$( swapon -s | sed -n 2p | awk '{ print $1 }' )
  [[ "$DIR" != "/var/swap" ]]
}

configure()
{
  cat  > /etc/systemd/system/ncp-swapfile.service <<'EOF'

[Unit]
Description= ncp-swapfile service

[Service]
Type=simple
ExecStart=/sbin/dphys-swapfile setup
ExecStartPost=/sbin/dphys-swapfile swapon
ExecStop=/sbin/dphys-swapfile swapoff

[Install]
Requires=nc-automount.services
After=nc-automount.service

EOF

  systemctl daemon-reload

  local ORIG=$( grep -oP "CONF_SWAPFILE=.*" /etc/dphys-swapfile | cut -f2 -d= )
  [[ "$ORIG" -ef "$SWAPFILE_" ]] && return
  test -d "$SWAPFILE_" && { echo "$SWAPFILE_ is a directory. Abort"; return 1; }

  [[ $( stat -fc%d / ) == $( stat -fc%d $( dirname "$SWAPFILE_" ) ) ]] && \
    echo -e "INFO: moving swapfile to another place in the same SD card\nIf you want to use an external mount, make sure it is properly set up"

  sed -i "s|#\?CONF_SWAPFILE=.*|CONF_SWAPFILE=$SWAPFILE_|" /etc/dphys-swapfile
  sed -i "s|#\?CONF_SWAPSIZE=.*|CONF_SWAPSIZE=$SWAPSIZE_|" /etc/dphys-swapfile
  grep -q vm.swappiness /etc/sysctl.conf || echo "vm.swappiness = 10" >> /etc/sysctl.conf && sysctl --load

  service stop dphys-swapfile 
  systemctl enable ncp-swapfile && systemctl restart ncp-swapfile && swapoff "$ORIG" && rm -f "$ORIG"
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

