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
INFO="If you are installing software other than NextCloud
that creates folders under '/var/log/' disable this feature"

configure()
{
  [[ $ACTIVE_ != "yes" ]] && {
    sed -i '/tmpfs \/var\/log.* in RAM$/d' /etc/fstab
    sed -i '/tmpfs \/tmp.* in RAM$/d'      /etc/fstab
    echo "Logs in SD. Reboot for changes to take effect"
    return
  }

  grep -q "Logs in RAM" /etc/fstab || cat >> /etc/fstab <<EOF
tmpfs /var/log tmpfs defaults,noatime,mode=1777,size=100M 0 0 # Logs in RAM
tmpfs /tmp     tmpfs defaults,noatime,mode=1777           0 0 # /tmp in RAM
EOF

  # unit to recreate required logdirs
  mkdir -p /usr/lib/systemd/system
  cat > /usr/lib/systemd/system/ramlogs.service <<'EOF'
[Unit]
Description=Populate ramlogs dir
Requires=network.target
Before=redis-server apache2 mysqld

[Service]
ExecStart=/bin/bash /usr/local/bin/ramlog-dirs.sh

[Install]
WantedBy=multi-user.target
EOF

  cat > /usr/local/bin/ramlog-dirs.sh <<'EOF'
#!/bin/bash
mkdir -p /var/log/mysql
chown mysql /var/log/mysql

mkdir -p /var/log/apache2
chown www-data /var/log/apache2

mkdir -p /var/log/redis
chown redis /var/log/redis
EOF
  systemctl enable ramlogs

  grep -q vm.swappiness /etc/sysctl.conf || echo "vm.swappiness = 10" >> /etc/sysctl.conf && sysctl --load
  echo "Logs in RAM. Reboot for changes to take effect"
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

