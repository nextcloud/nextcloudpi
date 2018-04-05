#!/bin/bash

# Periodically sync Nextcloud datafolder through rsync
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh nc-rsync.sh <IP> (<img>)
#
# See installer.sh instructions for details
#
# More at https://ownyourbits.com/2017/02/13/nextcloud-ready-raspberry-pi-image/
#

ACTIVE_=no
DESTINATION_=user@ip:/path/to/sync
SYNCDAYS_=3
DESCRIPTION="Periodically sync Nextcloud data through rsync"

INFO="DESTINATION can be a regular path for local sync
'user' needs SSH autologin from the NCP 'root' user at 'ip'"

install()
{
  apt-get update
  apt-get install --no-install-recommends -y rsync
}

configure()
{
  [[ $ACTIVE_ != "yes" ]] && { 
    rm /etc/cron.d/ncp-rsync-auto
    echo "automatic rsync disabled"
    return 0
  }

  local DATADIR
  DATADIR=$( sudo -u www-data php /var/www/nextcloud/occ config:system:get datadirectory ) || {
    echo -e "Error reading data directory. Is NextCloud running and configured?";
    return 1;
  }

  [[ "$DESTINATION_" =~ : ]] && {
    local NET="$( sed 's|:.*||' <<<"$DESTINATION_" )"
    local SSH=( ssh -o "BatchMode=yes" "$NET" )
    ${SSH[@]} : || { echo "SSH non-interactive not properly configured"; return 1; }
  }

  echo "0  5  */${SYNCDAYS_}  *  *  root  /usr/bin/rsync -aAx --delete \"$DATADIR\" \"$DESTINATION_\"" > /etc/cron.d/ncp-rsync-auto
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

