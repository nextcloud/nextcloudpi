#!/bin/bash

# Library to install software on Raspbian ARM through QEMU
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!

SSH=( ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ServerAliveInterval=5 -o ConnectTimeout=1 -o LogLevel=quiet )

function launch_install_qemu()
{
  local INSTALL_SCRIPT=$1
  local IMG=$2
  local IP=$3
  [[ "$IP" == "" ]] && { echo "usage: launch_install_qemu <script> <img> <IP>"; return 1; }
  test -f $IMG            || { echo "input file $IMG            not found"; return 1; }
  test -f $INSTALL_SCRIPT || { echo "input file $INSTALL_SCRIPT not found"; return 1; }

  # take a copy of the input image for processing ( append "-stage1" )
  local BASE=$( sed 's=-stage[[:digit:]]=='         <<< $IMG )
  local NUM=$(  sed 's=.*-stage\([[:digit:]]\)=\1=' <<< $IMG )
  [[ "$BASE" == "$IMG" ]] && NUM=0
  local IMGFILE="$BASE-stage$(( NUM+1 ))"
  cp -v $IMG $IMGFILE || return 1

  local NUM_REBOOTS=$( grep -c reboot $INSTALL_SCRIPT )
  while [[ $NUM_REBOOTS != -1 ]]; do
    launch_qemu $IMGFILE &
    sleep 10
    wait_SSH $IP
    sleep 120                               # FIXME for some reason, SSH is ready but blocks for PIXEL image
    launch_installation $INSTALL_SCRIPT 
    wait 
    NUM_REBOOTS=$(( NUM_REBOOTS-1 ))
  done
  echo "$IMGFILE generated successfully"
}

function launch_qemu()
{
  local IMG=$1
  test -f $1 || { echo "Image $IMG not found"; return 1; }
  test -d qemu-raspbian-network || git clone https://github.com/nachoparker/qemu-raspbian-network.git
  sed -i '30s/NO_NETWORK=1/NO_NETWORK=0/' qemu-raspbian-network/qemu-pi.sh
  echo "Starting QEMU image $IMG"
  ( cd qemu-raspbian-network && sudo ./qemu-pi.sh ../$IMG )
}

function wait_SSH()
{
  local IP=$1
  echo "Waiting for SSH to be up on $IP..."
  while true; do
    sshpass -praspberry ${SSH[@]} pi@$IP ls &>/dev/null && break
    sleep 1
  done
  echo "SSH is up"
}

function launch_installation()
{
  local INSTALL_SCRIPT=$1
  test -f $1 || { echo "File $INSTALL_SCRIPT not found"; return 1; }
  echo "Launching installation"
  cat $INSTALL_SCRIPT | sshpass -praspberry ${SSH[@]} pi@$IP
}

function pack_image()
{
  local IMGFILE="$1"
  local IMGOUT="$2"
  local TARNAME=$( basename $IMGOUT .img ).tar.bz2
  cp -v $( ls -1t $IMGFILE-stage* | head -1 ) $IMGOUT
  tar -I pbzip2 -cvf $TARNAME $IMGOUT &>/dev/null && \
    echo -e "$TARNAME packed successfully"
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

