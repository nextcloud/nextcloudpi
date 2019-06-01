#!/bin/bash

# Automatically apply Nextcloud updates
#
# Copyleft 2018 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at: https://ownyourbits.com
#


# just change this value and re-activate in update.sh to upgrade users
VERSION=15.0.8

configure() 
{
  [[ "$ACTIVE" != "yes" ]] && { 
    rm -f /etc/cron.daily/ncp-autoupdate-nc
    echo "automatic Nextcloud updates disabled"
    return 0
  }

  cat > /etc/cron.daily/ncp-autoupdate-nc <<EOF
#!/bin/bash

echo -e "[ncp-update-nc]"                          >> /var/log/ncp.log
/usr/local/bin/ncp-update-nc "$VERSION" 2>&1 | tee -a /var/log/ncp.log

if [[ \${PIPESTATUS[0]} -eq 0 ]]; then

  VER="\$( /usr/local/bin/ncc status | grep "version:" | awk '{ print \$3 }' )"

  sudo -u www-data php /var/www/nextcloud/occ notification:generate \
    "$NOTIFYUSER" "NextCloudPi" -l "Nextcloud was updated to \$VER"
fi
echo "" >> /var/log/ncp.log
EOF
  chmod 755 /etc/cron.daily/ncp-autoupdate-nc
  echo "automatic Nextcloud updates enabled"
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

