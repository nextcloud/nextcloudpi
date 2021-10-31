#!/bin/bash

# Format external USB drive for encryption by LUKS (dangerous)
#
# Copyleft 2021 by Thomas Heller
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at: https://ownyourbits.com
#

configure()
{
  [[ "$DEV" == "" ]] && {
    echo "error: please specify device"
    return 1
  }

  [[ "$DEVICE_LABEL" == "" ]] && {
    echo "error: please specify device label"
    return 2
  }

  [[ "$PARTITION_LABEL" == "" ]] && {
    echo "error: please specify partition label"
    return 3
  }

  [[ "$PASS" == "" ]] && {
    echo "error: please specify password"
    return 4
  }

  [[ ! -b "$DEV" ]] && {
    echo "error: $DEV is not a block device"
    return 5
  }

  if [[ -e /media/USBdrive ]]; then
    echo "warning: device may be currently mounted"
    echo "consider deactivating nc-automount or unmounting with nc-luks-close before formatting!"
  fi

  echo "formatting LUKS device $DEV ..."

  echo -n "$PASS" | cryptsetup luksFormat "$DEV" --label "$DEVICE_LABEL" -d - || {
    echo "error: cryptsetup format failed"
    return 6
  }

  echo "successfully formatted $DEV"

  echo "opening LUKS device $DEV ..."

  echo -n "$PASS" | cryptsetup open --type luks -d - "$DEV" nc || {
    echo "error: cryptsetup open failed"
    return 7
  }

  mkfs.btrfs -q /dev/mapper/nc -f -L "$PARTITION_LABEL" || {
   echo "error: mkfs.btrfs failed"
    return 8
  }

  echo "BTRFS file system successfully created on $DEV"

  echo "notice: consider enabling nc-automount to mount the device if you haven't already done so"
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
