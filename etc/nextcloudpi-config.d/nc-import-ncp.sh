#!/bin/bash

# Import NextCloudPi configuration
#
#
# Copyleft 2017 by Courtney Hicks
# GPL licensed (see end of file) * Use at your own risk!
#

FILE_=/media/USBdrive/ncp-config_xxxxxx.cfg

DESCRIPTION="Import NextCloudPi configuration from file"

configure() 
{
  [[ -f "$FILE_" ]] || { echo "export file $FILE_ does not exist"; return 1; }

  source /usr/local/etc/library.sh       || return 1
  cd /usr/local/etc/nextcloudpi-config.d || return 1

  # extract export
  local TMP="/tmp/ncp-export"
  rm -rf "$TMP"
  mkdir -p "$TMP"
  tar -xf "$FILE_" -C "$TMP"

  # restore configuration and activate
  for file in /"$TMP"/*; do
    local SCRIPT="$( basename "$file" .cfg ).sh"

    # restore
    [ -f /usr/local/etc/nextcloudpi-config.d/"$SCRIPT" ] && {
      local VARS=( $( grep "^[[:alpha:]]\+=" "$file" | cut -d= -f1 ) )
      local VALS=( $( grep "^[[:alpha:]]\+=" "$file" | cut -d= -f2 ) )
      for i in $( seq 0 1 ${#VARS[@]} ); do
        sed -i "s|^${VARS[$i]}_=.*|${VARS[$i]}_=${VALS[$i]}|" "$SCRIPT"
      done
    }

    # activate
    grep -q "^ACTIVE_=yes" "$SCRIPT" && echo && activate_script "$SCRIPT"
  done

  # cleanup
  rm -rf "$TMP"
  echo -e "\nconfiguration restored"
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
