#!/bin/bash

#!/bin/bash
# Nextcloud restore backup
#
# Copyleft 2019 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at nextcloudpi.com
#

install() { :; }

configure()
{
  [[ -d "$SNAPSHOT" ]] || { echo "$SNAPSHOT doesn't exist"; return 1; }

  local datadir mountpoint
  datadir=$( get_nc_config_value datadirectory ) || {
    echo -e "Error reading data directory. Is Nextcloud running?";
    return 1;
  }

  # file system check
  mountpoint="$( stat -c "%m" "$datadir" )" || return 1
  [[ "$( stat -fc%T "$mountpoint" )" != "btrfs" ]] && {
    echo "$datadir is not in a BTRFS filesystem"
    return 1
  }

  # file system check
  btrfs subvolume show "$SNAPSHOT" &>/dev/null || {
    echo "$SNAPSHOT is not a BTRFS snapshot"
    return 1
  }

  btrfs-snp $mountpoint autobackup 0 0 ../ncp-snapshots || return 1

  save_maintenance_mode
  btrfs subvolume delete   "$datadir" || return 1
  btrfs subvolume snapshot "$SNAPSHOT" "$datadir"
  restore_maintenance_mode
  ncp-scan

  echo "snapshot $SNAPSHOT restored"
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

