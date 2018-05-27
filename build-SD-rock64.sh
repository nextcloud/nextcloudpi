#!/bin/bash

# Batch creation of NextCloudPlus image for the Odroid HC1
#
# Copyleft 2018 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage: ./build-SD-odroid.sh <DHCP QEMU image IP>
#

IMG="NextCloudPi_Rock64_$( date  "+%m-%d-%y" ).img"

set -e

# get armbian
[[ -d armbian ]] || git clone https://github.com/armbian/build armbian

# get NCP modifications
mkdir -p armbian/userpatches
wget https://raw.githubusercontent.com/nextcloud/nextcloudpi/master/armbian.sh \
  -O armbian/userpatches/customize-image.sh

# generate image
armbian/compile.sh docker \                                                                                                                                                      2.62 L  ✔
  BOARD=rock64\
  BRANCH=default\
  KERNEL_ONLY=no\
  KERNEL_CONFIGURE=no\
  RELEASE=stretch\
  BUILD_DESKTOP=no\
  EXPERT=yes \
  LIB_TAG="development"\
  USE_CCACHE=yes\
  CLEAN_LEVEL=""\
  NO_APT_CACHER=no

# pack image
TAR=output/"$( basename "$IMG" .img ).tar.bz2"
pack_image "$IMG" "$TAR"

# test
# TODO

# upload
create_torrent "$TAR"
upload_ftp "$( basename "$TAR" .tar.bz2 )"
