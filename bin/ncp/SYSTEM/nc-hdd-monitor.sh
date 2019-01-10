#!/bin/bash

# Monitor HDD health automatically
#
# Copyleft 2018 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at https://ownyourbits.com
#



is_active()
{
  systemctl -q is-enabled smartd &>/dev/null
}

configure()
{
  local DRIVES=($(lsblk -ln | grep "^sd[[:alpha:]].*disk" | awk '{ print $1 }'))

  [[ ${#DRIVES[@]} == 0 ]] && {
    echo "no drives detected. Disabling.."
  }

  [[ "$ACTIVE" != yes ]] && {
    update-rc.d  smartd disable
    service      smartd stop
    echo "HDD monitor disabled"
    return 0
  }

  cat > /etc/smartd.conf <<EOF
# short scan every day at 1am, long one on sundays at 2am
DEVICESCAN -a -m $EMAIL -M exec /usr/local/etc/ncp-hdd-notif.sh -s (S/../.././01|L/../../7/02)
EOF

  cat > /usr/local/etc/ncp-hdd-notif.sh <<EOF
#!/bin/bash
EOF

  [[ "$EMAIL" != "" ]] && {
    cat >> /usr/local/etc/ncp-hdd-notif.sh <<EOF
sendmail "$EMAIL" <<EOFMAIL
Subject: Hard drive problems found

"\$SMARTD_MESSAGE"
EOFMAIL
EOF
  }

  cat >> /usr/local/etc/ncp-hdd-notif.sh <<EOF
wall "\$SMARTD_MESSAGE"
sudo -u www-data php /var/www/nextcloud/occ notification:generate \
  $NOTIFYUSER "NextCloudPi HDD health \$SMARTD_FAILTYPE" \
     -l "\$SMARTD_MESSAGE"
EOF
chmod +x /usr/local/etc/ncp-hdd-notif.sh

  for dr in "${DRIVES[@]}"; do smartctl --smart=on /dev/${dr} | sed 1,2d; done
  update-rc.d  smartd enable
  service      smartd start
  echo "HDD monitor enabled"
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
