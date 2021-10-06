#!/bin/bash

# Batch creation of NextCloudPi LXD image
#
# Copyleft 2021 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
#

set -e
source build/buildlib.sh

#CLEAN=0                    # Pass this envvar to skip cleaning download cache
IMG="NextCloudPi_LXD_$( date  "+%m-%d-%y" ).img"
IMG=tmp/"$IMG"

TAR=output/"$( basename "$IMG" .img ).tar.bz2"

test -f "$TAR" && { echo "$TAR already exists. Skipping... "; exit 0; }

##############################################################################

## preparations

test -f "$TAR" && { echo "$TAR already exists. Skipping... "; exit 0; }
set -e
prepare_dirs                   # tmp cache output

## BUILD NCP

echo -e "\e[1m\n[ Build NCP ]\e[0m"

lxc delete -f ncp 2>/dev/null || true
systemd-run --user --scope -p "Delegate=yes" lxc launch images:debian/buster ncp
lxc config device add ncp buildcode disk source="$(pwd)" path=/build
lxc exec ncp -- bash -c 'while [ "$(systemctl is-system-running 2>/dev/null)" != "running" ] && [ "$(systemctl is-system-running 2>/dev/null)" != "degraded" ]; do :; done'
lxc exec ncp -- bash -c 'CODE_DIR=/build bash /build/install.sh'
lxc exec ncp -- bash -c 'source /build/etc/library.sh; run_app_unsafe /build/post-inst.sh'
lxc config device remove ncp buildcode
lxc publish ncp -f --alias ncp/"${version}"

## pack
lxc export ncp "$TAR"

## test
#set_static_IP "$IMG" "$IP"
#test_image    "$IMG" "$IP"

# upload
create_torrent "$TAR"
upload_ftp "$( basename "$TAR" .tar.bz2 )"


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
