#!/bin/bash
# Batch creation of NextCloudPi images and containers
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

sleep 5

# make sure we don't accidentally include this
rm -f ncp-web/wizard.cfg

# Raspbian
build/build-SD-rpi.sh
IMG="$( ls -1t tmp/*.img | head -1 )"
build/build-SD-berryboot.sh "$IMG"

# Armbian
build/build-SD-armbian.sh odroidxu4 OdroidHC2
build/build-SD-armbian.sh rockpro64 RockPro64
build/build-SD-armbian.sh rock64 Rock64
build/build-SD-armbian.sh bananapi Bananapi
build/build-SD-armbian.sh odroidhc4 OdroidHC4
build/build-SD-armbian.sh odroidc4 OdroidC4
build/build-SD-armbian.sh odroidc2 OdroidC2
#build/build-SD-armbian.sh orangepizeroplus2-h5 OrangePiZeroPlus2

# VM
build/build-VM.sh

# LXD
build/build-LXD.sh

# Docker
build/build-docker.sh x86
build/build-docker.sh armhf
build/build-docker.sh arm64

[[ "$FTPPASS" == "" ]] && exit

export DOCKER_CLI_EXPERIMENTAL=enabled

# TODO test first
#&& {
  docker push ownyourbits/nextcloudpi-x86:latest
  docker push ownyourbits/nextcloudpi-x86:${version}
  docker push ownyourbits/nextcloud-x86:latest
  docker push ownyourbits/nextcloud-x86:${version}
  docker push ownyourbits/lamp-x86:latest
  docker push ownyourbits/lamp-x86:${version}
  docker push ownyourbits/debian-ncp-x86:latest
  docker push ownyourbits/debian-ncp-x86:${version}
#}

# TODO test first && {
  docker push ownyourbits/nextcloudpi-armhf:latest
  docker push ownyourbits/nextcloudpi-armhf:${version}
  docker push ownyourbits/nextcloud-armhf:latest
  docker push ownyourbits/nextcloud-armhf:${version}
  docker push ownyourbits/lamp-armhf:latest
  docker push ownyourbits/lamp-armhf:${version}
  docker push ownyourbits/debian-ncp-armhf:latest
  docker push ownyourbits/debian-ncp-armhf:${version}
#}

# TODO test first && {
  docker push ownyourbits/nextcloudpi-arm64:latest
  docker push ownyourbits/nextcloudpi-arm64:${version}
  docker push ownyourbits/nextcloud-arm64:latest
  docker push ownyourbits/nextcloud-arm64:${version}
  docker push ownyourbits/lamp-arm64:latest
  docker push ownyourbits/lamp-arm64:${version}
  docker push ownyourbits/debian-ncp-arm64:latest
  docker push ownyourbits/debian-ncp-arm64:${version}
#}

# Docker multi-arch
docker manifest create --amend ownyourbits/nextcloudpi:${version} \
  --amend ownyourbits/nextcloudpi-x86:${version} \
  --amend ownyourbits/nextcloudpi-armhf:${version} \
  --amend ownyourbits/nextcloudpi-arm64:${version}

docker manifest create --amend ownyourbits/nextcloudpi:latest \
  --amend ownyourbits/nextcloudpi-x86:latest \
  --amend ownyourbits/nextcloudpi-armhf:latest \
  --amend ownyourbits/nextcloudpi-arm64:latest


docker manifest annotate ownyourbits/nextcloudpi:${version} ownyourbits/nextcloudpi-x86:${version}   --os linux --arch amd64
docker manifest annotate ownyourbits/nextcloudpi:${version} ownyourbits/nextcloudpi-armhf:${version} --os linux --arch arm
docker manifest annotate ownyourbits/nextcloudpi:${version} ownyourbits/nextcloudpi-arm64:${version} --os linux --arch arm64

docker manifest annotate ownyourbits/nextcloudpi:latest ownyourbits/nextcloudpi-x86:latest   --os linux --arch amd64
docker manifest annotate ownyourbits/nextcloudpi:latest ownyourbits/nextcloudpi-armhf:latest --os linux --arch arm
docker manifest annotate ownyourbits/nextcloudpi:latest ownyourbits/nextcloudpi-arm64:latest --os linux --arch arm64

docker manifest push -p ownyourbits/nextcloudpi:${version}
docker manifest push -p ownyourbits/nextcloudpi:latest


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
