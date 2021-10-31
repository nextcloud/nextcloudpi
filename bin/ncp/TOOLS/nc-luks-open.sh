#!/bin/bash

# Mount external USB drive encrypted by LUKS
#
# Copyleft 2021 by Thomas Heller
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at: https://ownyourbits.com
#

configure()
{
  [[ -e /dev/mapper/nc ]] && {
    echo "encrypted device is already opened"
    return 0
  }

  [[ "$DEV" == "" ]] && {
    echo "error: please specify device"
    return 1
  }

  [[ "$PASS" == "" ]] && {
    echo "error: please specify password"
    return 2
  }

  [[ ! -b "$DEV" ]] && {
    echo "error: $DEV is not a block device"
    return 3
  }

  echo "opening LUKS device $DEV ..."

  echo -n "$PASS" | cryptsetup open --type luks -d - "$DEV" nc || {
    echo "error: cryptsetup open failed"
    return 4
  }

  echo "successfully opened $DEV"
}

install() { :; }

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
