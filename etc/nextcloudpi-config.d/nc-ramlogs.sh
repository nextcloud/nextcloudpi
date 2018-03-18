#!/bin/bash

# Data dir configuration script for NextCloudPi
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh nc-ramlogs.sh <IP> (<img>)
#
# See installer.sh instructions for details
#
# More at https://ownyourbits.com/
#

ACTIVE_=no
DESCRIPTION="mount logs in RAM to prevent SD degradation (faster, consumes more RAM)"

INFOTITLE="Warning"
INFO="You need to reboot for this change to take effect"

install()
{
  curl -Lo log2ram.tar.gz https://github.com/azlux/log2ram/archive/master.tar.gz
  tar xf log2ram.tar.gz
  cd log2ram-master
  sed -i '/systemctl enable log2ram/d' install.sh
  chmod +x install.sh && sudo ./install.sh
  cd ..
  rm -r log2ram-master log2ram.tar.gz
  rm /etc/cron.hourly/log2ram /usr/local/bin/uninstall-log2ram.sh
}

configure()
{
  [[ $ACTIVE_ != "yes" ]] && {
    systemctl disable log2ram
    systemctl stop    log2ram
    echo "Logs in SD. Reboot to take effect"
    return
  }
  systemctl enable log2ram
  systemctl start  log2ram

  echo "Logs in RAM. Reboot to take effect"
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

