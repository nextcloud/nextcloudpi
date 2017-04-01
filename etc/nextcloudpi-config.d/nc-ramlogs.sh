#!/bin/bash

# Data dir configuration script for NextCloudPi
# Tested with 2017-03-02-raspbian-jessie-lite.img
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
DESCRIPTION="mount logs in RAM to prevent SD card degradation (faster, consumes more RAM)"

configure()
{
  [[ $ACTIVE_ != "yes" ]] && {
    sed -i '/tmpfs \/var\/log.* in RAM$/d' /etc/fstab
    sed -i '/tmpfs \/tmp.* in RAM$/d'      /etc/fstab
    echo "Logs in SD. Reboot for changes to take effect"
    return
  }

  grep -q "Logs in RAM" /etc/fstab || cat >> /etc/fstab <<EOF
tmpfs /var/log tmpfs defaults,noatime,mode=1777 0 0 # Logs in RAM
tmpfs /tmp     tmpfs defaults,noatime,mode=1777 0 0 # /tmp in RAM
EOF

  local HTTPUNIT=/lib/systemd/system/apache2.service
  grep -q mkdir /etc/init.d/mysql   || sed -i "/\<start)/amkdir -p /var/log/mysql"   /etc/init.d/mysql
  grep -q mkdir /etc/init.d/apache2 || sed -i "/\<start)/amkdir -p /var/log/apache2" /etc/init.d/apache2
  grep -q mkdir $HTTPUNIT           || sed -i "/ExecStart/iExecStartPre=/bin/mkdir -p /var/log/apache2" $HTTPUNIT

  grep -q vm.swappiness /etc/sysctl.conf || echo "vm.swappiness = 10" >> /etc/sysctl.conf && sysctl --load
  echo "Logs in RAM. Reboot for changes to take effect"
}

install() { :; }
cleanup() { :; }

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

