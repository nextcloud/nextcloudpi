#!/bin/bash

# DuckDNS installation on Raspbian for NextCloudPi
#
#
# Copyleft 2017 by Courtney Hicks
# GPL licensed (see end of file) * Use at your own risk!
#


INSTALLDIR=duckdns
INSTALLPATH=/usr/local/etc/$INSTALLDIR
CRONFILE=/etc/cron.d/duckdns

configure() 
{
  local DOMAIN="$( sed 's|.duckdns.org||' <<<"$DOMAIN" )"
  if [[ $ACTIVE == "yes" ]]; then
    mkdir -p "$INSTALLPATH"

    # Creates duck.sh script that checks for updates to DNS records
    touch "$INSTALLPATH"/duck.sh
    touch "$INSTALLPATH"/duck.log
    echo -e "echo url=\"https://www.duckdns.org/update?domains=$DOMAIN&token=$TOKEN&ip=\" | curl -k -o "$INSTALLPATH"/duck.log -K -" > "$INSTALLPATH"/duck.sh

    # Adds file to cron to run script for DNS record updates and change permissions 
    touch $CRONFILE
    echo "*/5 * * * * root $INSTALLPATH/duck.sh >/dev/null 2>&1" > "$CRONFILE"
    chmod 700 "$INSTALLPATH"/duck.sh
    chmod +x "$CRONFILE"

    # First-time execution of duck script
    "$INSTALLPATH"/duck.sh > /dev/null 2>&1

    SUCCESS="$( cat $INSTALLPATH/duck.log )"

    # Checks for successful run of duck.sh
    if [[ $SUCCESS == "OK" ]]; then
      echo "DuckDNS is enabled"
    elif [[ $SUCCESS == "KO" ]]; then
      echo "DuckDNS install failed, is your information correct?"
    fi

    # Removes config files and cron job if ACTIVE_ is set to no
  elif [[ $ACTIVE == "no" ]]; then
    rm -f "$CRONFILE"
    rm -f "$INSTALLPATH"/duck.sh
    rm -f "$INSTALLPATH"/duck.log
    rmdir "$INSTALLPATH"
    echo "DuckDNS is now disabled"
  fi
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
