#!/bin/bash

# TODO
# config from the beginning and store it in a variable?
# install to real rpi without QEMU
# no dialog (automatic) version



# Generic software installer on QEMU emulated Raspbian image
# Tested with 2017-01-11-raspbian-jessie.img (and lite)
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
#  ./installer.sh <script.sh> <imgfile.img> <IP> 
#
# Notes:
#  Use a Raspbian image to be run on QEMU
#  Use any script that would run locally on the image
#  Use the IP of your running QEMU Raspbian image (DHCP should assign always the same)

INSTALL_SCRIPT=$1
IMGFILE=$2              # First argument is the image file to start from
IP=$3                   # Second argument is the QEMU Raspbian IP address
 
source library.sh       # initializes $IMGOUT

launch_install_qemu $INSTALL_SCRIPT $IMGFILE $IP || exit
pack_image                          $IMGFILE $IMGOUT


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

