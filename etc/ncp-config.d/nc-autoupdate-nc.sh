#!/bin/bash

# Automatically apply Nextcloud updates
#
# Copyleft 2018 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh nc-autoupdate-nc.sh <IP>
#
# See installer.sh instructions for details
# More at: https://ownyourbits.com
#

ACTIVE_=no
NOTIFYUSER_=ncp
DESCRIPTION="Automatically apply Nextcloud updates"
VERSION=13.0.2

configure() 
{
  [[ $ACTIVE_ != "yes" ]] && { 
    rm /etc/cron.daily/ncp-autoupdate-nc
    echo "automatic Nextcloud updates disabled"
    return 0
  }

  cat > /etc/cron.daily/ncp-autoupdate-nc <<EOF
#!/bin/bash
if /usr/local/bin/ncp-update-nc "$VERSION"; then
  VER="\$( sudo -u www-data php /var/www/nextcloud/occ status | grep "version:" | awk '{ print \$3 }' )"
  sudo -u www-data php /var/www/nextcloud/occ notification:generate \
    "$NOTIFYUSER_" "NextCloudPlus" -l "Nextcloud was updated to \$VER"
fi
EOF
  chmod a+x /etc/cron.daily/ncp-autoupdate-nc
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

