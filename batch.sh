#!/bin/bash

# Batch creation of NextCloudPi image
# Tested with 2017-01-11-raspbian-jessie.img (and lite)
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
#

INSTALL_SCRIPT=$1       # First argument is the script to be run inside Raspbian
IMGFILE=$2              # Second argument is the image file to start from ( empty for online installation )

                          ./install-nextcloud.sh     $IP
NO_CONFIG=1               ./installer.sh fail2ban.sh $IP $IMG
NO_CONFIG=1 NO_CFG_STEP=1 ./installer.sh no-ip.sh    $IP $IMG
NO_CONFIG=1 NO_CFG_STEP=1 ./installer.sh dnsmasq.sh  $IP $IMG

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
