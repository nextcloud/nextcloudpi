#!/bin/bash

# FreeDNS updater client installation on Raspbian 
#
# Copyleft 2017 by Panteleimon Sarantos <pantelis.fedora _a_t_ gmail _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh freedns.sh 
#
# See installer.sh instructions for details
#
#
#

ACTIVE_=no
UPDATEHASH_=abcdefghijklmnopqrstuvwxyzABCDEFGHIJK1234567
DOMAIN_=mynextcloud.example.com
UPDATEINTERVAL_=30
DESCRIPTION="DDNS FreeDNS client (need account)"

UPDATEURL=https://freedns.afraid.org/dynamic/update.php
URL="${UPDATEURL}?${UPDATEHASH_}"

install()
{
  apt-get update
  apt-get install --no-install-recommends -y dnsutils
  cat > /etc/systemd/system/freedns.service <<EOF
[Unit]
Description=FreeDNS client

[Service]
Type=simple
ExecStart=/usr/local/bin/freedns.sh

[Install]
WantedBy=default.target
EOF
}

configure() 
{
  [[ $ACTIVE_ != "yes" ]] && { 
    systemctl stop    freedns.timer
    systemctl disable freedns.timer
    systemctl daemon-reload
    echo "FreeDNS client is disabled"
    return 0
  }

  cat > /usr/local/bin/freedns.sh <<EOF
#!/bin/bash
echo "FreeDNS client started"
echo "${URL}"
registeredIP=\$(nslookup ${DOMAIN_}|tail -n2|grep A|sed s/[^0-9.]//g)
currentIP=\$(wget -q -O - http://checkip.dyndns.org|sed s/[^0-9.]//g)
    [ "\$currentIP" != "\$registeredIP" ] && {
        wget -q -O /dev/null ${URL}
  }
echo "Registered IP: \$registeredIP | Current IP: \$currentIP"
EOF
  chmod +744 /usr/local/bin/freedns.sh


  cat > /etc/systemd/system/freedns.timer <<EOF
[Unit] 
Description=Timer to run FreeDNS client per interval 

[Timer] 
OnBootSec=${UPDATEINTERVAL_}min
OnUnitActiveSec=${UPDATEINTERVAL_}min
Unit=freedns.service 

[Install] 
WantedBy=timers.target
EOF
  systemctl daemon-reload

  systemctl enable freedns.timer
  systemctl start  freedns.timer
  systemctl start  freedns.service
  
  cd /var/www/nextcloud
  sudo -u www-data php occ config:system:set trusted_domains 3 --value="$DOMAIN_"
  sudo -u www-data php occ config:system:set overwrite.cli.url --value=https://"$DOMAIN_"

  echo "FreeDNS client is enabled"
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
