#!/bin/bash

# Batch creation of NextcloudPi Armbian based images
#
# Copyleft 2018 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage: ./build-SD-armbian.sh <board_code> [<board_name>]
#

set -ex
source build/buildlib.sh

#CLEAN=0                    # Pass this envvar to avoid cleaning download cache
BOARD="$1"
BNAME="${2:-$1}"
NCPCFG=etc/ncp.cfg

echo -e "\e[1m\n[ Build NCP ${BNAME} ]\e[0m"

IMG="${IMG:-NextcloudPi_${BNAME}_$( date  "+%m-%d-%y" ).img}"
IMG=tmp/"$IMG"
TAR=output/"$( basename "$IMG" .img ).tar.bz2"


test -f "$TAR" && { echo "$TAR already exists. Skipping... "; exit 0; }

source etc/library.sh # sets RELEASE

prepare_dirs                   # tmp cache output

# get latest armbian
[[ -d armbian ]] || git clone https://github.com/armbian/build armbian
( cd armbian && git pull --ff-only --tags )

# add NCP modifications
mkdir -p armbian/userpatches armbian/userpatches/overlay
rm -f ncp-web/{wizard.cfg,ncp-web.cfg}
cp build/armbian/armbian.sh armbian/userpatches/customize-image.sh
rsync -Aax --delete --exclude-from .gitignore --exclude *.img --exclude *.bz2 . armbian/userpatches/overlay/

# GENERATE IMAGE

CONF=armbian/userpatches/config-ncp.conf

# default parameters
cat > "$CONF" <<EOF
BOARD="$BOARD"
BRANCH=current
RELEASE=${RELEASE%%-security}
KERNEL_ONLY=no
KERNEL_CONFIGURE=prebuilt
BUILD_DESKTOP=no
BUILD_MINIMAL=yes
USE_CCACHE=yes
EOF
[[ "$CLEAN" == "0" ]] && {
  cat >> "$CONF" <<EOF
  CLEAN_LEVEL=""          # study this: it is much faster, but generated images might be broken (#548)
  # NO_APT_CACHER=no      # this will also improve build times, but doesn't seem very reliable
EOF
}

# board specific parameters
EXTRA_CONF=build/armbian/"config-$BOARD".conf
[[ -f "$EXTRA_CONF" ]] && cat "$EXTRA_CONF" >> "$CONF"

# build
rm -rf armbian/output/images
mkdir -p armbian/userpatches
sed -e '/docker.*run/s/-it//' armbian/config/templates/config-docker.conf > armbian/userpatches/config-docker.conf
docker pull "ghcr.io/armbian/build:$(cut -d"." -f1-2 < armbian/VERSION)-$(dpkg --print-architecture)"
armbian/compile.sh docker ncp
rm "$CONF"

# pack image

[[ " $* " =~ " --pack " ]] && { mv armbian/output/images/Armbian*.img "$IMG" && pack_image "$IMG" "$TAR"; }

exit 0

# test
# TODO

# upload
#create_torrent "$TAR"
#upload_ftp "$( basename "$TAR" .tar.bz2 )"
