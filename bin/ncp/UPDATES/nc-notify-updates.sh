#!/bin/bash

# Install the latest News third party app
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at: https://ownyourbits.com
#



# check every hour
CHECKINTERVAL=1
NCDIR=/var/www/nextcloud

configure()
{
  [[ $ACTIVE != "yes" ]] && {
    rm -f /etc/cron.d/ncp-notify-updates
    service cron restart
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
/usr/local/bin/ncp-test-updates || { echo "NextCloudPi up to date"; exit 0; }

test -e \$NOTIFIED && [[ "\$( cat \$LATEST )" == "\$( cat \$NOTIFIED )" ]] && {
  echo "Found update from \$( cat \$VERFILE ) to \$( cat \$LATEST ). Already notified"
  exit 0
}

echo "Found update from \$( cat \$VERFILE ) to \$( cat \$LATEST ). Sending notification..."

IFACE=\$( ip r | grep "default via" | awk '{ print \$5 }' | head -1 )
IP=\$( ip a show dev "\$IFACE" | grep global | grep -oP '\d{1,3}(\.\d{1,3}){3}' | head -1 )

/usr/local/bin/ncc notification:generate \
  $USER "NextCloudPi update" \
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
/usr/local/bin/ncc notification:generate \
  $USER "NextCloudPi Unattended Upgrades" \
     -l "Packages automatically upgraded \$PKGS"
EOF
  chmod +x /usr/local/bin/ncp-notify-unattended-upgrade

  # check every hour at 40th minute
  echo -e "MAILTO=\"\"\n40  */${CHECKINTERVAL} *  *  *  root /usr/local/bin/ncp-notify-update && /usr/local/bin/ncp-notify-unattended-upgrade" > /etc/cron.d/ncp-notify-updates
  chmod 644 /etc/cron.d/ncp-notify-updates
  [[ -f /run/crond.pid ]] && service cron restart

  echo "update web notifications enabled"
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

