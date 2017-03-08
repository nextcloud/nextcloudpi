#!/bin/bash

# nextcloudpi-config installation on Raspbian 
# Tested with 2017-01-11-raspbian-jessie.img (and lite)
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh nextcloudpi-config.sh <IP> (<img>)
#
# See installer.sh instructions for details
#

CONFDIR=/usr/local/etc/nextcloudpi-config.d/

install()
{
  apt-get update
  apt-get install -y dialog
  mkdir -p $CONFDIR
  chown pi $CONFDIR        # TODO
  # scp dnsmasq.sh no-ip.sh pi@192.168.0.130:/usr/local/etc/nextcloudpi-config.d
  # scp library nextcloudpi-config pi@192.168.0.130:/usr/local/bin/
}

configure()
{
  echo nothin
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

