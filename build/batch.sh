#!/bin/bash
# Batch creation of NextcloudPi images and containers
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage: ./batch.sh
#

set -e
source build/buildlib.sh          # initializes $IMGNAME

## BUILDING

[[ "$FTPPASS" == "" ]] && {
  echo -e "\e[1mNo FTPPASS variable found, FTP won't work.\nYou can ^C to cancel now\e[0m"
}

[[ "$CLEAN" != "0" ]] && {
  echo -e "\e[1mNOTE: CLEAN is enabled\nYou can ^C to cancel now\e[0m"
}

[[ "$SKIP_TESTS" == "1" ]] && {
  echo -e "\e[1mNOTE: SKIP_TESTS is enabled\nYou can ^C to cancel now\e[0m"
}

sleep 5

# make sure we don't accidentally include this
rm -f ncp-web/wizard.cfg

# LXD
build/build-LXD.sh

# Docker x86
build/build-docker.sh x86

# VM
build/build-VM.sh

# Tests
[[ "${SKIP_TESTS}" != 1 ]] && {
  test_lxc
  test_docker
  test_vm
}

# Docker other
build/build-docker.sh armhf
build/build-docker.sh arm64

# Raspbian
build/build-SD-rpi.sh
IMG="$(ls -1t tmp/*.img | head -1)"
build/build-SD-berryboot.sh "$IMG"

# Armbian
export LIB_TAG=master # if we want to pin down a specific armbian version
build/build-SD-armbian.sh odroidxu4 OdroidHC2
build/build-SD-armbian.sh rockpro64 RockPro64
build/build-SD-armbian.sh rock64 Rock64
build/build-SD-armbian.sh bananapi Bananapi
build/build-SD-armbian.sh odroidhc4 OdroidHC4
build/build-SD-armbian.sh odroidc4 OdroidC4
build/build-SD-armbian.sh odroidc2 OdroidC2
#build/build-SD-armbian.sh orangepizeroplus2-h5 OrangePiZeroPlus2

# Uploads
[[ "$FTPPASS" == "" ]] && exit
upload_docker
upload_images


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
