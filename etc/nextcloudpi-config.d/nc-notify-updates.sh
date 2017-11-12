#!/bin/bash

# Install the latest News third party app
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh nc-notify-updates.sh <IP> (<img>)
#
# See installer.sh instructions for details
# More at: https://ownyourbits.com
#

ACTIVE_=yes
USER_=admin
CHECKINTERVAL=60
DESCRIPTION="Notify in NC when a NextCloudPi update is available"

NCDIR=/var/www/nextcloud

install()
{
  # timers
  cat > /etc/systemd/system/nc-notify-updates.service <<EOF
[Unit]
Description=Notify in NC when a NextCloudPi update is available

[Service]
Type=simple
ExecStart=/usr/local/bin/ncp-notify-update
ExecStartPost=/usr/local/bin/ncp-notify-unattended-upgrade

[Install]
WantedBy=default.target
EOF
}

configure()
{
  [[ $ACTIVE_ != "yes" ]] && {
    systemctl stop    nc-notify-updates.timer
    systemctl disable nc-notify-updates.timer
    echo "update web notifications disabled"
    return 0
  }

  # code
  cat > /usr/local/bin/ncp-notify-update <<EOF
#!/bin/bash
VERFILE=/usr/local/etc/ncp-version
LATEST=/var/run/.ncp-latest-version
NOTIFIED=/var/run/.ncp-version-notified

test -e \$LATEST || exit 0;
ncp-test-updates || { echo "NextCloudPi up to date"; exit 0; }

test -e \$NOTIFIED && [[ "\$( cat \$LATEST )" == "\$( cat \$NOTIFIED )" ]] && { 
  echo "Found update from \$( cat \$VERFILE ) to \$( cat \$LATEST ). Already notified" 
  exit 0
}

echo "Found update from \$( cat \$VERFILE ) to \$( cat \$LATEST ). Sending notification..."

IFACE=\$( ip r | grep "default via" | awk '{ print \$5 }' )
IP=\$( ip a | grep "global \$IFACE" | grep -oP '\d{1,3}(\.\d{1,3}){3}' | head -1 )

sudo -u www-data php /var/www/nextcloud/occ notification:generate \
  $USER_ "NextCloudPi update" \
     -l "Update from \$( cat \$VERFILE ) to \$( cat \$LATEST ) is available. Update from https://\$IP:4443"

cat \$LATEST > \$NOTIFIED
EOF
  chmod +x /usr/local/bin/ncp-notify-update

  cat > /usr/local/bin/ncp-notify-unattended-upgrade <<EOF
#!/bin/bash

LOGFILE=/var/log/unattended-upgrades/unattended-upgrades.log
STAMPFILE=/var/run/.ncp-notify-unattended-upgrades
VERFILE=/usr/local/etc/ncp-version

test -e "\$LOGFILE" || { echo "\$LOGFILE not found"; exit 1; }

# find lines with package updates
LINE=\$( grep "INFO Packages that will be upgraded:" "\$LOGFILE" )

[[ "\$LINE" == "" ]] && { echo "no new upgrades"; exit 0; }

# extract package names
PKGS=\$( sed 's|^.*Packages that will be upgraded: ||' <<< "\$LINE" | tr '\\n' ' ' )

# mark lines as read
sed -i 's|INFO Packages that will be upgraded:|INFO Packages that will be upgraded :|' \$LOGFILE

echo -e "Packages automatically upgraded: \$PKGS\\n"

# notify
sudo -u www-data php /var/www/nextcloud/occ notification:generate \
  $USER_ "NextCloudPi Unattended Upgrades" \
     -l "Packages automatically upgraded \$PKGS"
EOF
  chmod +x /usr/local/bin/ncp-notify-unattended-upgrade

  # timer
  cat > /etc/systemd/system/nc-notify-updates.timer <<EOF
[Unit]
Description=Timer notify NCP updates in browser

[Timer]
OnBootSec=${CHECKINTERVAL}min
OnUnitActiveSec=${CHECKINTERVAL}min
Unit=nc-notify-updates.service

[Install]
WantedBy=timers.target
EOF

  systemctl daemon-reload
  systemctl enable nc-notify-updates.timer
  systemctl start  nc-notify-updates.timer
  echo "update web notifications enabled"
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

