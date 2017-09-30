#!/bin/bash

# Format a USB external drive as a unique ext4 partition
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh nc-format-USB.sh <IP> (<img>)
#
# See installer.sh instructions for details
# More at: https://ownyourbits.com
#

LABEL_=myCloudDrive
DESCRIPTION="Format an external USB drive as a ext4 partition (dangerous)"

INFOTITLE="Instructions for USB drive formatting" 
INFO="Make sure that ONLY the USB drive that you want to format is plugged in.
careful, this will destroy any data in the USB drive

** YOU WILL LOSE ALL YOUR USB DATA **"

configure() 
{
  # count all disk devices except mmcblk0
  local NUM=$(( $( lsblk -l -n | awk '{ print $6 }' | grep disk | wc -l ) - 1 ))

  # only one plugged in
  [[ $NUM != 1 ]] && { 
    echo "ERROR: counted $NUM devices. Please, only plug in the USB drive you want to format to ext4";
    return 1; 
  }

  # disable nc-automount if enabled
  killall -STOP udiskie 2>/dev/null

  # umount if mounted
  umount /media/USBdrive* &> /dev/null

  # check still not mounted
  for dir in $( ls -d /media/* 2>/dev/null ); do
    mountpoint -q $dir && { echo "$dir is still mounted"; return 1; }
  done

  # do it
  local NAME=( $( lsblk -l -n | grep -v mmcblk | grep disk | awk '{ print $1 }' ) )
  [[ ${#NAME[@]} != 1 ]] && { echo "unexpected error"; return 1; }

  wipefs -a -f /dev/"$NAME"                              || return 1
  parted /dev/"$NAME" --script -- mklabel gpt            || return 2
  parted /dev/"$NAME" --script -- mkpart primary 0% 100% || return 3
  sleep 0.5
  mkfs.ext4 -q -E lazy_itable_init=0,lazy_journal_init=0 -F /dev/"${NAME}1" -L "$LABEL_"

  # enable nc-automount if enabled
  killall -CONT udiskie 2>/dev/null
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

