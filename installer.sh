#!/bin/bash

# Generic software installer for Raspbian. Online on a running RPi, or offline with QEMU.
# Tested with 2017-03-02-raspbian-jessie-lite.img
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
#
#  To install to an image using QEMU
#
#      ./installer.sh <script.sh> <IP> <imgfile.img> 
#
#  To install directly to a running Raspberry Pi through SSH, omit the image parameter
#
#      ./installer.sh <script.sh> <IP> 
#
#  In order to skip interactive configuration (you can edit the variables at the top of the scripts)
#
#      NO_CONFIG=1 ./installer.sh <script.sh> <IP> (<imgfile.img>)
#
#  In order to use other than default SSH user and/or password, you can specify it in the same way
#
#      PIUSER=nacho PIPASS=ownyourbits ./installer.sh <script.sh> <IP> (<imgfile.img>)
#
# Notes:
#  Use a Raspbian image to be run on QEMU
#  Use any script that would run locally on the image
#  Use the IP of your running QEMU Raspbian image (DHCP should assign always the same)
#
# More at: https://ownyourbits.com/2017/03/05/generic-software-installer-for-raspbian/
#

INSTALL_SCRIPT=$1       # First argument is the script to be run inside Raspbian
IP=$2                   # Second argument is the QEMU Raspbian IP address
IMGFILE=$3              # Third argument is the image file to start from ( empty for online installation )
 
source etc/library.sh   # initializes $IMGNAME

test -f $IMGNAME && { echo "INFO: $IMGNAME already exists. Skip generation ... "; exit 0; }

config $INSTALL_SCRIPT || exit 1    # Initializes $INSTALLATION_CODE

if [[ "$IMGFILE" != "" ]]; then
  launch_install_qemu "$IMGFILE" $IP       || { sudo killall qemu-system-arm; exit 1; }    # initializes $IMGOUT
  pack_image          "$IMGOUT" "$IMGNAME" 
else
  launch_installation_online $IP
fi


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
