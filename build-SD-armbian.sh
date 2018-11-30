#!/bin/bash

# Batch creation of NextCloudPi Armbian based images
#
# Copyleft 2018 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage: ./build-SD-armbian.sh <board_code> [<board_name>]
#

#CLEAN=0                    # Pass this envvar to avoid cleaning download cache
BOARD="$1"
BNAME="${2:-$1}"

IMG="NextCloudPi_${BNAME}_$( date  "+%m-%d-%y" ).img"
IMG=tmp/"$IMG"

set -e
source buildlib.sh

prepare_dirs                   # tmp cache output

# get latest armbian
[[ -d armbian ]] || git clone https://github.com/armbian/build armbian
( cd armbian && git pull --ff-only --tags )

# add NCP modifications
mkdir -p armbian/userpatches armbian/userpatches/overlay
rm -f ncp-web/{wizard.cfg,ncp-web.cfg}
cp armbian.sh armbian/userpatches/customize-image.sh
rsync -Aax --delete --exclude-from .gitignore --exclude *.img --exclude *.bz2 . armbian/userpatches/overlay/

# GENERATE IMAGE

# default parameters
cat > armbian/config-docker-guest.conf <<EOF
BOARD="$BOARD"
BRANCH=default
RELEASE=stretch
KERNEL_ONLY=no
KERNEL_CONFIGURE=no
BUILD_DESKTOP=no
USE_CCACHE=yes
EOF
[[ "$CLEAN" == "0" ]] && {
  cat >> armbian/config-docker-guest.conf <<EOF
  CLEAN_LEVEL=""          # study this: it is much faster, but generated images might be broken (#548)
  # NO_APT_CACHER=no      # this will also improve build times, but doesn't seem very reliable
EOF
}

# board specific parameters
CONF="config-$BOARD".conf
[[ -f "$CONF" ]] && cat "$CONF" >> armbian/config-docker-guest.conf

# build
rm -rf armbian/output/images
armbian/compile.sh docker
rm armbian/config-docker-guest.conf

# pack image
mv armbian/output/images/Armbian*.img "$IMG"
TAR=output/"$( basename "$IMG" .img ).tar.bz2"
pack_image "$IMG" "$TAR"

# test
# TODO

# upload
create_torrent "$TAR"
upload_ftp "$( basename "$TAR" .tar.bz2 )"
