#!/bin/bash

# Data dir configuration script for NextcloudPi
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at https://ownyourbits.com/
#



is_active()
{
  systemctl -q is-active log2ram &>/dev/null || systemctl -q is-active armbian-ramlog &>/dev/null
}

install()
{
  VERSION=1.5.2
  [[ -d /var/log.hdd ]] || [[ -d /var/hdd.log ]] && { echo "log2ram detected, not installing"; return; }
  cd /tmp
  curl -Lo log2ram.tar.gz https://github.com/azlux/log2ram/archive/${VERSION}.tar.gz
  tar xf log2ram.tar.gz
  cd log2ram-${VERSION}
  sed -i '/systemctl -q is-active log2ram/d' install.sh
  sed -i '/systemctl enable log2ram/d' install.sh
  chmod +x install.sh && sudo ./install.sh
  cd ..
  rm -r log2ram-${VERSION} log2ram.tar.gz
  rm /etc/cron.daily/log2ram /usr/local/bin/uninstall-log2ram.sh
}

configure()
{
  [[ -f /lib/systemd/system/armbian-ramlog.service ]] && local ramlog=armbian-ramlog || local ramlog=log2ram

  [[ $ACTIVE != "yes" ]] && {
    systemctl disable "$ramlog"
    systemctl stop    "$ramlog"
    echo "Logs in SD. Reboot to take effect"
    return
  }

  systemctl enable "$ramlog"
  systemctl start  "$ramlog"

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
