#!/bin/bash

# Data dir configuration script for NextCloudPi
# Tested with 2017-03-02-raspbian-jessie-lite.img
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh nc-wifi.sh <IP> (<img>)
#
# See installer.sh instructions for details
#
# More at https://ownyourbits.com/
#

DESCRIPTION="Configure your Wi-Fi connection"

install()
{
  apt-get update
  apt install -y --no-install-recommends wicd-curses
  systemctl disable wicd 
}

show_info()
{
  whiptail --yesno \
           --backtitle "NextCloudPi configuration" \
           --title "Instructions to configure Wi-Fi" \
"1) Select a Wi-Fi network
2) Press right arrow ->
3) Enter the passphrase for your Wi-Fi
4) Make sure to select 'connect automatically'
5) F10 to save
6) C to connect" \
  20 90
}

configure()
{
  # Installation in QEMU (without a wireless interface) produces 
  # wicd installation to generate 'wireless_interface = None'.
  # It does not hurt to restart it to wlan0 for RPi3 & zero w
  sed -i 's|^wireless_interface = None|wireless_interface = wlan0|' /etc/wicd/manager-settings.conf

  # First booting with a connected ethernet cable produces
  # wicd daemon to generate 'wireless_interface = '. (issue #6)
  # It does not hurt to restart it to wlan0 for RPi3 & zero w
  sed -i 's|^wireless_interface = $|wireless_interface = wlan0|'    /etc/wicd/manager-settings.conf

  systemctl stop    dhcpcd
  systemctl disable dhcpcd
  systemctl enable  wicd 
  systemctl start   wicd

  wicd-curses
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

