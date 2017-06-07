#!/bin/bish

# Prepare a Raspbian image (download, resize and update)
# Tested with 2017-03-02-raspbian-jessie-lite.img
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage: ./installer.sh prepare.sh <DHCP QEMU image IP> <image>
#


STATE_FILE=/home/pi/.installation_state
APTINSTALL="apt-get install -y --no-install-recommends"

install()
{
  test -f $STATE_FILE && STATE=$( cat $STATE_FILE 2>/dev/null )
  if [ "$STATE" == "" ]; then

    # RESIZE IMAGE
    ##########################################

    SECTOR=$( fdisk -l /dev/sda | grep Linux | awk '{ print $2 }' )
    echo -e "d\n2\nn\np\n2\n$SECTOR\n\nw\n" | fdisk /dev/sda || true

    echo 0 > $STATE_FILE 
    nohup reboot &>/dev/null &
  elif [ "$STATE" == "0" ]; then

    # UPDATE EVERYTHING
    ##########################################
    resize2fs /dev/sda2

    apt-get update
    apt-get upgrade -y
    apt-get dist-upgrade -y
    $APTINSTALL rpi-update 
    echo -e "y\n" | PRUNE_MODULES=1 rpi-update
  fi
}

configure(){ :; }

cleanup()
{
  [ "$STATE" != "0" ] && return
  apt-get autoremove
  apt-get clean
  rm /var/lib/apt/lists/* -r
  rm -f /home/pi/.bash_history

  systemctl disable ssh
  rm $STATE_FILE
  nohup halt &>/dev/null &
}

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
