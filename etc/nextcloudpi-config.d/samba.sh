#!/bin/bash

# SAMBA server for Raspbian 
# Tested with 2017-03-02-raspbian-jessie-lite.img
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh samba.sh <IP> (<img>)
#
# See installer.sh instructions for details
# More at: https://ownyourbits.com
#

DIR_=/media/USBdrive/ncdata/admin/files
USER_=pi
PWD_=raspberry
DESCRIPTION="SMB/CIFS file server (for Mac/Linux/Windows)"

install()
{
  apt-get update
  apt-get install --no-install-recommends -y samba
  update-rc.d smbd disable

  # the directory needs to be recreated if we are using nc-ramlogs
  grep -q mkdir /etc/init.d/smbd || sed -i "/\<start)/amkdir -p /var/log/samba" /etc/init.d/smbd
}

show_info()
{
  whiptail --yesno \
           --backtitle "NextCloudPi configuration" \
           --title "Instructions for external synchronization" \
"If we intend to modify the data folder through SAMBA,
then we have to synchronize NextCloud to make it aware of the changes. \n
This can be done manually or automatically using 'nc-scan' and 'nc-scan-auto' 
from 'nextcloudpi-config'" \
  20 90
}

configure()
{
  # CHECKS
  ################################
  [ -d "$DIR_" ] || { echo -e "INFO: directory $DIR_ does not exist. Creating"; mkdir -p "$DIR_"; }
  [[ $( stat -fc%d / ) == $( stat -fc%d $DIR_ ) ]] && \
    echo -e "INFO: mounting a in the SD card\nIf you want to use an external mount, make sure it is properly set up"

  # CONFIG
  ################################
  sed -i '/\[NextCloudPi\]/,+5d' /etc/samba/smb.conf
  cat >> /etc/samba/smb.conf <<EOF
[NextCloudPi]
	path = $DIR_
	writeable = yes
;	browseable = yes
	valid users = $USER_
EOF

  update-rc.d smbd defaults
  update-rc.d smbd enable
  service smbd start

  usermod -aG www-data $USER_
  echo -e "$PWD_\n$PWD_" | smbpasswd -s -a $USER_
  sudo chmod g+w $DIR_
}

cleanup()
{
  apt-get autoremove -y
  apt-get clean
  rm /var/lib/apt/lists/* -r
  rm -f /home/pi/.bash_history
  systemctl disable ssh
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

