#!/bin/bash

# Format a USB external drive as a unique BTRFS partition
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at: https://ownyourbits.com
#


configure()
{
  # count all disk devices except mmcblk0
  local mounts
  local found=false
  local root_disk

  while read -r line
  do
    if [[ "$found" != "true" ]]
    then
      mounts="$(rev <<<"$line" | cut -d" " -f1 | rev)"
      [[ "$mounts" =~ (^|'\x0a')/($|'\x0a') ]] && {
        echo "$line"
        found=true
      }
    fi

    if [[ "$found" == "true" ]]
    then
      if [[ "$(cut -d" " -f6 <<<"$line")" == "disk" ]]
      then
        root_disk="$(cut -d" " -f1 <<<"$line")"
        break
      fi
    fi
  done < <( lsblk -nr | tac )

  [[ -n "$root_disk" ]] || {
    echo "ERROR: Could not determine root disk!"
    return 1
  }

  local NUM=$( lsblk -ln | grep "^sd[[:alpha:]].*disk" | grep -v "^$root_disk" | awk '{ print $1 }' | wc -l )

  # only one plugged in
  [[ $NUM != 1 ]] && {
    echo "ERROR: counted $NUM devices. Please, only plug in the USB drive you want to format";
    return 1;
  }

  DATADIR="$(ncc config:system:get datadirectory || true)"
  if [[ $( stat -fc%d / ) == $( stat -fc%d "$DATADIR" ) ]] || [[ -z "$DATADIR" ]] && [[ "$ALLOW_DATA_DIR_REMOVAL" != "yes" ]]
  then
    echo "ERROR: Data directory is on USB drive (or can't be determined) and removal of data directory was not explicitly allowed." \
      "Please move the data directory to SD before formatting the USB drive." \
      "If you are certain that the data directory is not on this USB drive, check 'Allow data directory removal'." \
      "Exiting..."
    return 1
  fi

  # disable nc-automount if enabled
  killall -STOP udiskie 2>/dev/null

  # umount if mounted
  umount /media/USBdrive* &> /dev/null

  # check still not mounted
  for dir in $( ls -d /media/* 2>/dev/null ); do
    mountpoint -q $dir && { echo "$dir is still mounted"; return 1; }
  done

  # do it
  local NAME=( $( lsblk -ln | grep "^sd[[:alpha:]].*disk" | awk '{ print $1 }' ) )
  [[ ${#NAME[@]} != 1 ]] && { echo "unexpected error"; return 1; }

  wipefs -a -f /dev/"$NAME"                              || return 1
  parted /dev/"$NAME" --script -- mklabel gpt            || return 2
  parted /dev/"$NAME" --script -- mkpart primary 0% 100% || return 3
  sleep 0.5
  mkfs.btrfs -q /dev/"${NAME}1" -f -L "$LABEL"
  local RET=$?

  # enable nc-automount if enabled
  killall -CONT udiskie 2>/dev/null
  [ $RET -eq 0 ] && echo "Drive $NAME formatted successfuly and labeled $LABEL"
  return $RET
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

