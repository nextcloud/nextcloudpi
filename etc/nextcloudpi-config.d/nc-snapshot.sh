#!/bin/bash
# Nextcloud BTRFS snapshots
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh nc-snapshot.sh <IP> (<img>)
#
# See installer.sh instructions for details
#
# More at https://ownyourbits.com/2017/02/13/nextcloud-ready-raspberry-pi-image/
#

LIMIT_=4
DESCRIPTION="Create BTRFS snapshot of the datadir"

INFO="Snapshots take up very little space because only the differences from one 
to the next are saved. This requires the datadir to be in a BTRFS filesystem"

BASEDIR=/var/www

configure()
{
  local DATADIR
  DATADIR=$( cd "$BASEDIR"/nextcloud; sudo -u www-data php occ config:system:get datadirectory ) || {
    echo -e "Error reading data directory. Is NextCloud running and configured?";
    return 1;
  }
  local SNAPSHOT=${DATADIR}_$( date +"%F" )

  # file system check
  [[ "$( stat -fc%T "$DATADIR" )" != "btrfs" ]] && {
    echo "The datadir is not in a BTRFS filesystem"
    return 1
  }
  local DESTDIR="$( dirname "$DATADIR" )"

  # do it
  sudo -u www-data php "$BASEDIR"/nextcloud/occ maintenance:mode --on

  [[ -d "$SNAPSHOT" ]] && {
    btrfs subvolume delete "$SNAPSHOT" &>/dev/null
    rm -rf "$SNAPSHOT"                 &>/dev/null
  }
  btrfs subvolume snapshot -r "$DATADIR" "$SNAPSHOT" || return 1

  # prune older backups
  [[ $LIMIT_ != 0 ]] && {

    local SNAPS=( $( btrfs subvolume list -s --sort=gen "$DESTDIR" | awk '{ print $14 }' ) )
    cd "$DESTDIR" || return 1
    [[ ${#SNAPS[@]} -gt $LIMIT_ ]] && \
      echo "Pruning old snapshots..." && \
      for (( i=0; i < $(( ${#SNAPS[@]} - LIMIT_ )); i++ ));do 
        btrfs subvolume delete "${SNAPS[$i]}"
      done
  }

  sudo -u www-data php "$BASEDIR"/nextcloud/occ maintenance:mode --off
  echo -e "snapshot $SNAPSHOT generated"
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

