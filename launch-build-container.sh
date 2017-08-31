#!/bin/bash

# Launch a Raspbian-docker instance in QEMU and build container
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
#   ./launch-build-container.sh <IP> # Use the IP of your running QEMU Raspbian image
#
# More at https://ownyourbits.com
#

IP=$1          # First argument is the QEMU Raspbian IP address

source etc/library.sh       # initializes $IMGNAME

test -f raspbian_docker.img || ./prepare-build-env-docker.sh "$IP" || exit 1

./installer.sh docker/build-container.sh "$IP" raspbian_docker.img || exit 1

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
