#!/bin/bash

# Batch creation of NextCloudPi image for the Banana Pi
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage: ./build-SD-bananapi.sh <DHCP QEMU image IP>
#

IMG="NextCloudPi_bananapi_$( date  "+%m-%d-%y" ).img"

set -e

# get armbian
[[ -d armbian ]] || git clone https://github.com/armbian/build armbian

# get NCP modifications
mkdir -p armbian/userpatches
wget https://raw.githubusercontent.com/nextcloud/nextcloudpi/master/armbian.sh \
  -O armbian/userpatches/customize-image.sh

# generate image
armbian/compile.sh docker \
  BOARD=bananapi\
  BRANCH=next\
  KERNEL_ONLY=no\
  KERNEL_CONFIGURE=no\
  RELEASE=stretch\
  BUILD_DESKTOP=no\
  CLEAN_LEVEL=""\
  USE_CCACHE=yes\
  NO_APT_CACHER=no

# pack image
TAR=output/"$( basename "$IMG" .img ).tar.bz2"
pack_image "$IMG" "$TAR"

# testing
# TODO

# uploading
create_torrent "$TAR"
upload_ftp "$( basename "$TAR" .tar.bz2 )"
