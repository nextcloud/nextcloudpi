#!/bin/bash

# Batch creation of NextcloudPi LXC image
#
# Copyleft 2021 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
#

set -e
source build/buildlib.sh

echo -e "\e[1m\n[ Build NCP LXC ]\e[0m"

#CLEAN=0                    # Pass this envvar to skip cleaning download cache
IMG="NextcloudPi_LXC_$( date  "+%m-%d-%y" ).img"
IMG=tmp/"$IMG"

TAR=output/"$( basename "$IMG" .img ).tar.bz2"

test -f "$TAR" && { echo "$TAR already exists. Skipping... "; exit 0; }

##############################################################################

## preparations

test -f "$TAR" && { echo "$TAR already exists. Skipping... "; exit 0; }
set -e
prepare_dirs                   # tmp cache output

## BUILD NCP

# TODO sudo
sudo lxc-destroy ncp -f
sudo lxc-create -n ncp -t download -B btrfs -- --dist debian --release buster --arch amd64 # TODO vars for distro and stuff
sudo cp lxc_config /var/lib/lxc/ncp/config
sudo lxc-start -n ncp
sudo lxc-attach -n ncp --clear-env -- bash -c 'while [ "$(systemctl is-system-running 2>/dev/null)" != "running" ] && [ "$(systemctl is-system-running 2>/dev/null)" != "degraded" ]; do :; done'
sudo lxc-attach -n ncp --clear-env -- CODE_DIR="$(pwd)" bash /build/install.sh
sudo lxc-attach -n ncp --clear-env -- bash -c 'source /build/etc/library.sh; run_app_unsafe /build/post-inst.sh'
sudo lxc-attach -n ncp --clear-env -- bash -c "echo '$(basename "$IMG")' > /usr/local/etc/ncp-baseimage"
sudo lxc-attach -n ncp --clear-env -- poweroff

exit 0 # TODO

## pack
pack_image "$IMG" "$TAR"

## test
#set_static_IP "$IMG" "$IP"
#test_image    "$IMG" "$IP" # TODO fix tests

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
