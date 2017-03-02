#!/bin/bash

# Nextcloud installation on QEMU emulated Raspbian image
# Tested with 2017-01-11-raspbian-jessie.img (and lite)
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
#   ./install-nextcloud.sh <IP> # Use the IP of your running QEMU Raspbian image
#
# Notes:
#   Set DOWNLOAD=0 if you have already downloaded an image. Rename it to nextcloudpi.img

IP=$1          # First argument is the QEMU Raspbian IP address
DOWNLOAD=1     # Download the latest image
EXTRACT=1      # Extract the image from zip, so start from 0
#IMG=raspbian_latest
IMG=raspbian_lite_latest
INSTALL_SCRIPT=nextcloud.sh
IMGFILE="NextCloudPi_$( date  "+%m-%d-%y" ).img-stage0"

source library.sh       # initializes $IMGOUT

[[ "$DOWNLOAD" == "1" ]] && { wget https://downloads.raspberrypi.org/$IMG -O $IMG.zip || exit; }
[[ "$DOWNLOAD" == "1" ]] || [[ "$EXTRACT"  == "1" ]] && {
  unzip $IMG.zip && \
  mv *-raspbian-*.img $IMGFILE && \
  qemu-img resize $IMGFILE +1G || exit 
}

IMGOUT="NextCloudPi_$( date  "+%m-%d-%y" ).img"

launch_install_qemu $INSTALL_SCRIPT $IMGFILE $IP || exit
pack_image $IMGFILE $IMGOUT


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

