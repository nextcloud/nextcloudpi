#!/bin/bash
# Batch creation of NextCloudPi images and containers
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage: ./batch.sh
#

set -e

version=$(git describe --tags --always)
version=${version%-*-*}

## BUILDING
source buildlib.sh          # initializes $IMGNAME

[[ "$FTPPASS" == "" ]] && {
  echo -e "\e[1mNo FTPPASS variable found, FTP won't work.\nYou can ^C to cancel now\e[0m"
  sleep 5
}

# Raspbian
./build-SD-rpi.sh
IMG="$( ls -1t tmp/*.img | head -1 )"
./build-SD-berryboot.sh "$IMG"

# Armbian
./build-SD-armbian.sh odroidxu4 OdroidHC2
./build-SD-armbian.sh rockpro64 RockPro64
./build-SD-armbian.sh rock64 Rock64
./build-SD-armbian.sh bananapi Bananapi
#./build-SD-armbian.sh orangepizeroplus2-h5 OrangePiZeroPlus2

# VM
./build-VM.sh

# Docker
./build-docker.sh x86
./build-docker.sh armhf
./build-docker.sh arm64

[[ "$FTPPASS" == "" ]] && exit

export DOCKER_CLI_EXPERIMENTAL=enabled

# TODO test first
#&& {
  docker push ownyourbits/nextcloudpi-x86
  docker push ownyourbits/nextcloudpi-x86:${version}
  docker push ownyourbits/nextcloud-x86
  docker push ownyourbits/nextcloud-x86 :${version}
  docker push ownyourbits/lamp-x86
  docker push ownyourbits/lamp-x86:${version}
  docker push ownyourbits/debian-ncp-x86
  docker push ownyourbits/debian-ncp-x86:${version}
#}

# TODO test first && {
  docker push ownyourbits/nextcloudpi-armhf
  docker push ownyourbits/nextcloudpi-armhf:${version}
  docker push ownyourbits/nextcloud-armhf
  docker push ownyourbits/nextcloud-armhf:${version}
  docker push ownyourbits/lamp-armhf
  docker push ownyourbits/lamp-armhf:${version}
  docker push ownyourbits/debian-ncp-armhf
  docker push ownyourbits/debian-ncp-armhf:${version}
#}

# TODO test first && {
  docker push ownyourbits/nextcloudpi-arm64
  docker push ownyourbits/nextcloudpi-arm64:${version}
  docker push ownyourbits/nextcloud-arm64
  docker push ownyourbits/nextcloud-arm64:${version}
  docker push ownyourbits/lamp-arm64
  docker push ownyourbits/lamp-arm64:${version}
  docker push ownyourbits/debian-ncp-arm64
  docker push ownyourbits/debian-ncp-arm64:${version}
#}

# Docker multi-arch
docker manifest create --amend ownyourbits/nextcloudpi \
  ownyourbits/nextcloudpi-x86 \
  ownyourbits/nextcloudpi-armhf \
  ownyourbits/nextcloudpi-arm64


docker manifest annotate ownyourbits/nextcloudpi ownyourbits/nextcloudpi-x86   --os linux --arch amd64
docker manifest annotate ownyourbits/nextcloudpi ownyourbits/nextcloudpi-armhf --os linux --arch arm
docker manifest annotate ownyourbits/nextcloudpi ownyourbits/nextcloudpi-arm64 --os linux --arch arm64v8

docker manifest push -p ownyourbits/nextcloudpi

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
