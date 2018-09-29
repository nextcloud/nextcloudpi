#!/bin/bash

# Periodically generate previews for the gallery
#
# Copyleft 2018 by Timo Stiefel
# GPL licensed (see end of file) * Use at your own risk!
#

ACTIVE_=no
STARTTIME_=240

DESCRIPTION="Periodically generate previews for the gallery"
INFO="Set the time in minutes after midnight in STARTTIME."

configure()
{
  [[ $ACTIVE_ != "yes" ]] && { 
    rm /etc/cron.d/nc-previews-auto
    service cron restart
    echo "Automatic preview generation disabled"
    return 0
  }
  
  # set crontab
  local HOURS MINS
    HOUR=$(( STARTTIME_ / 60   ))
    MINS=$(( STARTTIME_ % 60   ))
  
  echo "${MINS}  ${HOUR}  *  *  *  php /var/www/nextcloud/occ preview:pre-generate" > /etc/cron.d/nc-previews-auto
  service cron restart

  echo "Automatic preview generation enabled"
  return 0
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
