#!/bin/bash

# Periodically sync Nextcloud datafolder through rsync
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at https://ownyourbits.com/2017/02/13/nextcloud-ready-raspberry-pi-image/
#

install()
{
  apt-get update
  apt-get install --no-install-recommends -y rsync
}

configure()
{
  [[ $ACTIVE != "yes" ]] && { 
    rm -f /etc/cron.d/ncp-rsync-auto
    echo "automatic rsync disabled"
    return 0
  }

  local DATADIR
  DATADIR=$( sudo -u www-data php /var/www/nextcloud/occ config:system:get datadirectory ) || {
    echo -e "Error reading data directory. Is NextCloud running and configured?";
    return 1;
  }

  [[ "$DESTINATION" =~ : ]] && {
    local NET="$( sed 's|:.*||' <<<"$DESTINATION" )"
    local SSH=( ssh -o "BatchMode=yes" "$NET" )
    ${SSH[@]} : || { echo "SSH non-interactive not properly configured"; return 1; }
  }

  echo "0  5  */${SYNCDAYS}  *  *  root  /usr/bin/rsync -ax -e \"ssh -p $PORTNUMBER\" --delete \"$DATADIR\" \"$DESTINATION\"" > /etc/cron.d/ncp-rsync-auto
  chmod 644 /etc/cron.d/ncp-rsync-auto
  service cron restart

  echo "automatic rsync enabled"
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

