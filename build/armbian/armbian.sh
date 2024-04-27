#!/bin/bash

# arguments: $RELEASE $LINUXFAMILY $BOARD $BUILD_DESKTOP

# This is the image customization script for NextCloudPi on Armbian
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at https://ownyourbits.com/2017/02/13/nextcloud-ready-raspberry-pi-image/
#

set -e

echo 'Running user script...'

ARMBIAN_RELEASE=$1
LINUXFAMILY=$2
BOARD=$3
BUILD_DESKTOP=$4

cd /tmp/overlay
NCPCFG=etc/ncp.cfg
source etc/library.sh # sets RELEASE

# need sudo access that does not expire during build
chage -d -1 root

# install NCP
echo -e "\nInstalling NextCloudPi"

hostname -F /etc/hostname # fix 'sudo resolve host' errors

CODE_DIR="$(pwd)" DBG=x bash install.sh

echo -e "\nPostinstall..."
run_app_unsafe post-inst.sh

# disable SSH by default, it can be enabled through ncp-web
systemctl disable ssh

# disable armbian autologin
rm -f /etc/systemd/system/getty@.service.d/override.conf
rm -f /etc/systemd/system/serial-getty@.service.d/override.conf
rm -f /root/.not_logged_in_yet
sed -i 's|^root::|root:x:|' /etc/passwd

basename "$IMG" | tee /usr/local/etc/ncp-baseimage

cd -


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
