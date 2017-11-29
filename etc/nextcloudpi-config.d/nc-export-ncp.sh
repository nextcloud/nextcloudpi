#!/bin/bash

# Export NextCloudPi configuration
#
#
# Copyleft 2017 by Courtney Hicks
# GPL licensed (see end of file) * Use at your own risk!
#

DIR_=/media/USBdrive/

DESCRIPTION="Export NextCloudPi configuration"

configure() 
{
  [[ -d "$DIR_" ]] || { echo "directory $DIR_ does not exist"; return 1; }

  local DESTFILE="$DIR_"/ncp-config_$( date +"%Y%m%d" ).tar 
  rm -rf /tmp/ncp-export
  mkdir -p /tmp/ncp-export
  cd /tmp/ncp-export || return 1

  for file in /usr/local/etc/nextcloudpi-config.d/*; do
    VARS=( $( grep "^[[:alpha:]]\+_=" "$file" | cut -d= -f1 | sed 's|_$||' ) )
    VALS=( $( grep "^[[:alpha:]]\+_=" "$file" | cut -d= -f2 ) )
    local CONFIG=""
    for i in $( seq 0 1 $(( ${#VARS[@]} - 1 )) ); do
      CONFIG+="${VARS[$i]}=${VALS[$i]}\n"
    done
    echo -e "$CONFIG" > "$( basename "$file" .sh ).cfg"
  done

  tar -cf "$DESTFILE" *

  cd $OLDPWD
  rm -rf /tmp/ncp-export
  echo -e "configuration exported to $DESTFILE"
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
