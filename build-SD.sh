#!/bin/bash

# Batch creation of NextCloudPi image
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage: ./batch.sh <DHCP QEMU image IP>
#

source buildlib.sh          # initializes $IMGNAME

IP=$1                       # First argument is the QEMU Raspbian IP address


[[ "$FTPPASS" == "" ]] && { 
  echo -e "\e[1mNo FTPPASS variable found, FTP won't work.\nYou probably want to cancel now"
  sleep 5
}

## BUILDING

NC_INSTALL=etc/nextcloudpi-config.d/nc-nextcloud.sh
NC_CONFIG=etc/nextcloudpi-config.d/nc-init.sh

IMGBASE="NextCloudPi_$( date  "+%m-%d-%y" )_base.img"

export NO_CONFIG=1          # skip interactive configuration

## BUILD

download_resize_raspbian_img 1G "$IMGBASE" || exit 1

NO_HALT_STEP=1 ./installer.sh prepare.sh          "$IP" "$IMGBASE"                    || exit 1
               ./installer.sh lamp.sh             "$IP" "$( ls -1t *.img | head -1 )" || exit 1
               ./installer.sh $NC_INSTALL         "$IP" "$( ls -1t *.img | head -1 )" || exit 1
               ./installer.sh nextcloudpi.sh      "$IP" "$( ls -1t *.img | head -1 )" || exit 1
               ./installer.sh $NC_CONFIG          "$IP" "$( ls -1t *.img | head -1 )" || exit 1
               ./installer.sh raspbian-cleanup.sh "$IP" "$( ls -1t *.img | head -1 )" || exit 1
#              ./installer.sh build-devel.sh "$IP" "$( ls -1t *.img | head -1 )" || exit 1

## PACKING
 
IMGFILE=$( ls -1t *.img | head -1 )
IMGNAME=$( basename "$IMGFILE" _base_prepare_lamp_nc-nextcloud_nextcloudpi_nc-init_raspbian-cleanup.img )

[[ "$IMGNAME" != "" ]] || exit 1

pack_image "$IMGFILE" "$IMGNAME.img" 

## TESTING

launch_qemu "$IMGNAME.img" &
sleep 10
wait_SSH "$IP"
sleep 180                         # Wait for the services to start. Improve this ( wait HTTP && trusted domains )
tests/tests.py "$IP" || exit 1

ssh_pi "$IP" sudo halt

## UPLOADING

create_torrent "${IMGNAME}.tar.bz2"
upload_ftp "$IMGNAME" || true

## CLEANUP

mkdir -p partial && mv NextCloudPi*.bz2 partial
rm -f *.img

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
