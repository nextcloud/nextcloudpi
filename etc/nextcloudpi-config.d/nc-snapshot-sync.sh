#!/bin/bash

# Sync Nextcloud BTRFS snapshots
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh nc-snapshot-sync.sh <IP> (<img>)
#
# See installer.sh instructions for details
#
# More at https://ownyourbits.com/2017/02/13/nextcloud-ready-raspberry-pi-image/
#

ACTIVE_=no
SNAPDIR_=/media/USBdrive/ncp-snapshots
DESTINATION_=/media/myBackupDrive/ncp-snapshots
COMPRESSION_=no
SYNCDAYS_=1
DESCRIPTION="Sync BTRFS snapshots to USBdrive or remote machine"

INFO="Use format user@ip:/path/to/snapshots for remote sync
'user' needs permissions for the 'btrfs' command at 'ip'
'user' needs SSH autologin from the NCP 'root' user at 'ip'
Only use compression for internet transfer, because it uses many resources"

install()
{
  apt-get update
  apt-get install -y --no-install-recommends pv
  wget https://raw.githubusercontent.com/nachoparker/btrfs-sync/master/btrfs-sync -O /usr/local/bin/btrfs-sync
  chmod +x /usr/local/bin/btrfs-sync
  ssh-keygen -N "" -f /root/.ssh/id_rsa 
}

configure()
{
  [[ $ACTIVE_ != "yes" ]] && { 
    rm /etc/cron.d/ncp-snapsync-auto
    service cron restart
    echo "snapshot sync disabled"
    return 0
  }

  # checks
  [[ -d "$SNAPDIR_" ]] || { echo "$SNAPDIR_ does not exist"; return 1; }

  [[ "$DESTINATION_" =~ : ]] && {
    local NET="$( sed 's|:.*||' <<<"$DESTINATION_" )"
    local DST="$( sed 's|.*:||' <<<"$DESTINATION_" )"
    local SSH=( ssh -o "BatchMode=yes" "$NET" )
    ${SSH[@]} : || { echo "SSH non-interactive not properly configured"; return 1; }
  } || DST="$DESTINATION_"
  [[ "$( ${SSH[@]} stat -fc%T "$DST" )" != "btrfs" ]] && {
    echo "$DESTINATION_ is not in a BTRFS filesystem"
    return 1
  }

  [[ "$COMPRESSION_" == "yes" ]] && ZIP="-z"

  echo "30  4  */${SYNCDAYS_}  *  *  root  /usr/local/bin/btrfs-sync -qd $ZIP \"$SNAPDIR_\" \"$DESTINATION_\"" > /etc/cron.d/ncp-snapsync-auto
  service cron restart
  echo "snapshot sync enabled"
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

