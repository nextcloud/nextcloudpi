#!/bin/bash

# Periodically synchronize NextCloud for externally modified files
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at: https://ownyourbits.com
#

ACTIVE_=no
SCANINTERVAL_=60
DESCRIPTION="Periodically scan NC for externally modified files"

INFOTITLE="Instructions for auto synchronization"
INFO="Set the time in minutes in SCANINTERVAL.

>>> If there are too many files this can greatly affect performance. <<<"

configure() 
{
    [[ $ACTIVE_ != "yes" ]] && { 
    rm -f /etc/cron.d/ncp-scan-auto
    service cron restart
    echo "automatic scans disabled"
    return 0
  }

  # set crontab
  local DAYS HOURS MINS
  DAYS=$(( SCANINTERVAL_ / 1440 ))
  if [[ "$DAYS" != "0" ]]; then 
    DAYS="*/$DAYS" HOUR="1" MINS="15"
  else
    DAYS="*" 
    HOUR=$(( SCANINTERVAL_ / 60   ))
    MINS=$(( SCANINTERVAL_ % 60   ))
    MINS="*/$MINS"
    [[ $HOUR == 0 ]] && HOUR="*" || { HOUR="*/$HOUR" MINS="15"; }
  fi

  echo "${MINS}  ${HOUR}  ${DAYS}  *  *  root /usr/local/bin/ncp-scan" > /etc/cron.d/ncp-scan-auto
  service cron restart

  echo "automatic scans enabled"
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

