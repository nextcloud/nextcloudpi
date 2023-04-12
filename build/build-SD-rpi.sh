#!/bin/bash

# Batch creation of NextcloudPi image
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage: ./batch.sh <DHCP QEMU image IP>
#

set -e"$DBG"
source build/buildlib.sh

echo -e "\e[1m\n[ Build NCP Raspberry Pi ]\e[0m"

URL="https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2022-09-26/2022-09-22-raspios-bullseye-arm64-lite.img.xz"
SIZE=4G                     # Raspbian image size
#CLEAN=0                    # Pass this envvar to skip cleaning download cache
IMG="${IMG:-NextcloudPi_RPi_$( date  "+%m-%d-%y" ).img}"
TAR=output/"$( basename "$IMG" .img ).tar.bz2"

##############################################################################

test -f "$TAR" && { echo "$TAR already exists. Skipping... "; exit 0; }
pgrep -f qemu-arm-static     &>/dev/null && { echo "qemu-arm-static already running. Abort"; exit 1; }
pgrep -f qemu-aarch64-static &>/dev/null && { echo "qemu-aarch64-static already running. Abort"; exit 1; }

## preparations

IMG=tmp/"$IMG"

trap clean_chroot_raspbian EXIT
prepare_dirs                   # tmp cache output
download_raspbian "$URL" "$IMG"
resize_image      "$IMG" "$SIZE"
update_boot_uuid  "$IMG"       # PARTUUID has changed after resize

# make sure we don't accidentally disable first run wizard
rm -f ncp-web/{wizard.cfg,ncp-web.cfg}

## BUILD NCP

prepare_chroot_raspbian "$IMG"

mkdir raspbian_root/tmp/ncp-build
rsync -Aax --exclude-from .gitignore --exclude *.img --exclude *.bz2 . raspbian_root/tmp/ncp-build

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
  sudo chroot raspbian_root /bin/bash <<'EOFCHROOT'
    set -ex

    # allow oldstable
    apt-get update --allow-releaseinfo-change

    # As of 10-2018 this upgrades raspi-kernel and messes up wifi and BTRFS
    #apt-get upgrade -y
    #apt-get dist-upgrade -y

    # As of 03-2018, you dont get a big kernel update by doing
    # this, so better be safe. Might uncomment again in the future
    #$APTINSTALL rpi-update
    #echo -e "y\n" | PRUNE_MODULES=1 rpi-update

    # this image comes without resolv.conf ??
    echo 'nameserver 1.1.1.1' >> /etc/resolv.conf

    # install NCP
    cd /tmp/ncp-build || exit 1
    systemctl daemon-reload
    CODE_DIR="$(pwd)" bash install.sh

    # work around dhcpcd Raspbian bug
    # https://lb.raspberrypi.org/forums/viewtopic.php?t=230779
    # https://github.com/nextcloud/nextcloudpi/issues/938
    apt-get update
    apt-get install -y --no-install-recommends haveged
    systemctl enable haveged.service

    # harden SSH further for Raspbian
    sed -i 's|^#PermitRootLogin .*|PermitRootLogin no|' /etc/ssh/sshd_config

    # cleanup
    source etc/library.sh && run_app_unsafe post-inst.sh
    rm /etc/resolv.conf
    rm -rf /tmp/ncp-build
EOFCHROOT

basename "$IMG" | sudo tee raspbian_root/usr/local/etc/ncp-baseimage

trap '' EXIT
clean_chroot_raspbian

## pack
[[ "$*" =~ .*" --pack ".* ]] && pack_image "$IMG" "$TAR"

exit 0

## test

#set_static_IP "$IMG" "$IP"
#test_image    "$IMG" "$IP" # TODO fix tests

# upload
#create_torrent "$TAR"
#upload_ftp "$( basename "$TAR" .tar.bz2 )"


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
