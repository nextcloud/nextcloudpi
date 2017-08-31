#!/bin/bash

# Create a Raspbian image with docker
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
#   ./prepare-build-env-docker.sh <IP> # Use the IP of your running QEMU Raspbian image
#
# Notes:
#   Set DOWNLOAD=0 if you have already downloaded an image. 
#   Set EXTRACT=0  if you have already extracted the image.
#
# More at https://ownyourbits.com
#

IP=$1          # First argument is the QEMU Raspbian IP address

source etc/library.sh       # initializes $IMGNAME

IMGBASE="raspbian_docker_base.img"

export NO_CONFIG=1          # skip interactive configuration

download_resize_raspbian_img 3G $IMGBASE || exit 1

NO_HALT_STEP=1 ./installer.sh prepare.sh            "$IP" "$IMGBASE"                    || exit 1
               ./installer.sh docker/docker-env.sh  "$IP" "$( ls -1t *.img | head -1 )" || exit 1

IMGFILE=$( ls -1t *.img | head -1 )
IMGOUT="raspbian_docker.img"

pack_image "$IMGFILE" "$IMGOUT" 

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
