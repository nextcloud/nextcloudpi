#!/bin/bash

# Batch creation of NextCloudPi image
# Tested with 2017-03-02-raspbian-jessie-lite.img
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage: ./batch.sh <DHCP QEMU image IP>
#

source etc/library.sh       # initializes $IMGNAME

IP=$1                       # First argument is the QEMU Raspbian IP address
NC_INSTALL=etc/nextcloudpi-config.d/nc-nextcloud.sh
NC_CONFIG=etc/nc-init.sh

IMGBASE="NextCloudPi_$( date  "+%m-%d-%y" )_base.img"

export NO_CONFIG=1           # skip interactive configuration

NO_HALT_STEP=1 ./install-nextcloud.sh        $IP $IMGBASE
               ./installer.sh $NC_INSTALL    $IP $( ls -1t *.img | head -1 )
               ./installer.sh $NC_CONFIG     $IP $( ls -1t *.img | head -1 )
               ./installer.sh nextcloudpi.sh $IP $( ls -1t *.img | head -1 )

IMGFILE=$( ls -1t *.img | head -1 )
IMGOUT=$( basename "$IMGFILE" _base_nc-nextcloud_nextcloudpi.img ).img

pack_image "$IMGFILE" "$IMGOUT" 
md5sum $( ls -1t *.img | head -1 )

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
