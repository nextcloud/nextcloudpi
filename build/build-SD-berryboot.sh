#!/bin/bash

# Generate Berryboot image from Raspbian based image
#
# Copyleft 2018 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage: ./build-SD-berryboot.sh <img>
#

set -e
source build/buildlib.sh

echo -e "\e[1m\n[ Build NCP Berryboot ]\e[0m"

SRC="$1"
IMG="NextcloudPi_RPi_Berryboot_$( date  "+%m-%d-%y" ).img"
TAR=output/"$( basename "$IMG" .img ).tar.bz2"

test -f "$TAR" && { echo "$TAR already exists. Skipping... "; exit 0; }

[[ -f "$SRC" ]] || { echo "$SRC not found"; exit 1; }

# convert to Berryboot

mount_raspbian "$SRC"
  sudo bash -c "cat > raspbian_root/etc/fstab" <<EOF
/dev/mmcblk0p1  /boot           vfat    defaults          0       2
/dev/mmcblk0p2  /               ext4    defaults,noatime  0       1
EOF
#sudo rm raspbian_root/etc/console-setup/cached_UTF-8_del.kmap.gz # TODO


sudo mksquashfs raspbian_root "$IMG"  -comp lzo -e lib/modules
umount_raspbian

## pack
pack_image "$IMG" "$TAR"

# upload
create_torrent "$TAR"
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
