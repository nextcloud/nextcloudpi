#!/bin/bash

# Library to install software on Raspbian ARM through QEMU
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!

function launch_install_qemu()
{
  local INSTALL_SCRIPT=$1
  local IMGFILE=$2
  local IP=$3
  [[ "$IP" == "" ]] && { echo "usage: launch_install_qemu <script> <img> <IP>"; exit; }
  local SSH="ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ServerAliveInterval=5 -o ConnectTimeout=1 -o LogLevel=quiet"
  local NUM_REBOOTS=$( grep -c reboot $INSTALL_SCRIPT )

  test -d qemu-raspbian-network || git clone https://github.com/nachoparker/qemu-raspbian-network.git
  sed -i '30s/NO_NETWORK=1/NO_NETWORK=0/' qemu-raspbian-network/qemu-pi.sh

  while [[ $NUM_REBOOTS != -1 ]]; do
    echo "Starting QEMU"
    cd qemu-raspbian-network
    sudo ./qemu-pi.sh ../$IMGFILE &
    cd -

    sleep 10
    echo "Waiting for SSH to be up"
    while true; do
      sshpass -praspberry $SSH pi@$IP ls &>/dev/null && break
      sleep 1
    done

    sleep 120
    echo "Launching installation"
    cat $INSTALL_SCRIPT | sshpass -praspberry $SSH pi@$IP
    wait 
    NUM_REBOOTS=$(( NUM_REBOOTS-1 ))
  done
  echo "$IMGFILE generated successfully. Compressing"
  local TARNAME=$( basename $IMGFILE ).tar.bz2
  test -f $TARNAME || tar -I pbzip2 -cvf $TARNAME  $IMGFILE
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

