#!/bin/bash

# Batch creation of NextCloudPi VM image
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage: ./batch.sh <DHCP QEMU image IP>
#

set -e
source build/buildlib.sh

echo -e "\e[1m\n[ Build NCP VM ]\e[0m"

IP=${1:-192.168.0.145}      # For QEMU automated testing (optional)
SIZE=3G                     # Raspbian image size
#CLEAN=0                    # Pass this envvar to skip cleaning download cache
IMG="${IMG:-NextcloudPi_VM_$( date  "+%m-%d-%y" ).img}"
IMG=tmp/"$IMG"
VM="/var/lib/libvirt/images/ncp-vm.img"

TAR=output/"$( basename "$IMG" .img ).tar.bz2"

test -f "$TAR" && { echo "$TAR already exists. Skipping... "; exit 0; }

##############################################################################

## preparations

test -f "$TAR" && { echo "$TAR already exists. Skipping... "; exit 0; }
prepare_dirs                   # tmp cache output

## BUILD NCP

export DEB_RELEASE=$(jq -r .release < etc/ncp.cfg)
cd build/
vagrant destroy -f
vagrant box update
vagrant up --provider=libvirt --provision
cd -
sleep 10
sudo qemu-img rebase -b "" "$VM"

sudo chown "$USER" "$VM"
sudo cp -a --reflink=auto --sparse=auto "$VM" "$IMG"

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
