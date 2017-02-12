#!/bin/bash

# Nextcloud installation on QEMU emulated Raspbian image
# Tested with 2017-01-11-raspbian-jessie.img (and lite)
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
#   ./install-image.sh <IP> # Use the IP of your running QEMU Raspbian image
#
# Notes:
#   Set DOWNLOAD=0 if you have already downloaded an image. Rename it to nextcloudpi.img

IP=$1          # First argument is the QEMU Raspbian IP address
DOWNLOAD=1     # Download the latest image
#IMG=raspbian_latest
IMG=raspbian_lite_latest

[[ "$IP" == "" ]] && { echo "usage: ./install-image.sh <IP>"; exit; }

SSH="ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ServerAliveInterval=5 -o ConnectTimeout=1 -o LogLevel=quiet"
IMGFILE="NextCloudPi_$( date  "+%m-%d-%y" ).img"

if [[ "$DOWNLOAD" == "1" ]]; then
  wget https://downloads.raspberrypi.org/$IMG -O $IMG.zip && \
  unzip $IMG.zip && \
  mv *-raspbian-*.img $IMGFILE && \
  qemu-img resize $IMGFILE +1G
fi

test -d qemu-raspbian-network || git clone https://github.com/nachoparker/qemu-raspbian-network.git
sed -i '30s/NO_NETWORK=1/NO_NETWORK=0/' qemu-raspbian-network/qemu-pi.sh

NUM_REBOOTS=$( grep -c reboot install-nextcloud.sh )
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

  sleep 90
  echo "Launching installation"
  cat install-nextcloud.sh | sshpass -praspberry $SSH pi@$IP
  wait 
  NUM_REBOOTS=$(( NUM_REBOOTS-1 ))
done
echo "$IMGFILE generated successfully"

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

