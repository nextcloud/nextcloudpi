#!/bin/bash

# Batch creation of NextCloudPi images and containers
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage: ./batch.sh <DHCP QEMU image IP>
#

source buildlib.sh          # initializes $IMGNAME

IP=$1                       # First argument is the QEMU Raspbian IP address


## BUILDING

# Raspbian
./build-SD.sh "$IP"

# docker x86
docker pull debian:stretch-slim
make nextcloudpi-x86 && {
  docker push ownyourbits/nextcloudpi-x86 
  docker push ownyourbits/nextcloud-x86 
  docker push ownyourbits/lamp-x86
  docker push ownyourbits/debian-ncp-x86
}

# docker armhf
[[ -f docker-armhf/raspbian_docker.img ]] || \
  ./installer.sh docker-armhf/docker-env.sh "$IP" raspbian_lite.img # && mv
./installer.sh docker-armhf/build-container.sh "$IP" docker-armhf/raspbian_docker.img

# Armbian
git clone https://github.com/armbian/build armbian
wget https://raw.githubusercontent.com/nextcloud/nextcloudpi/master/armbian.sh \
  -O armbian/userpatches/customize-image.sh
armbian/compile.sh docker \
  BOARD=odroidxu4\
  BRANCH=next\
  KERNEL_ONLY=no\
  KERNEL_CONFIGURE=no\
  RELEASE=stretch\
  BUILD_DESKTOP=no\
  CLEAN_LEVEL=""\
  NO_APT_CACHER=no

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
