#!/bin/bash

#
# NextcloudPi scheduled datadir BTRFS snapshots
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at https://ownyourbits.com/2017/02/13/nextcloud-ready-raspberry-pi-image/
#


install()
{
  wget https://raw.githubusercontent.com/nachoparker/btrfs-snp/master/btrfs-snp -O /usr/local/bin/btrfs-snp
  chmod +x /usr/local/bin/btrfs-snp
}

configure()
{
  [[ "$ACTIVE" != "yes" ]] && {
    rm -f /etc/cron.hourly/btrfs-snp
    echo "automatic snapshots disabled"
    return 0
  }

  cat > /etc/cron.hourly/btrfs-snp <<EOF
#!/bin/bash

source /usr/local/etc/library.sh

DATADIR="\$(get_nc_config_value datadirectory)" || {
  echo -e "Error reading data directory. Is Nextcloud running and configured?";
  exit 1;
}

# file system check
MOUNTPOINT="\$(stat -c "%m" "\$DATADIR")" || return 1
[[ "\$( stat -fc%T "\$MOUNTPOINT" )" != "btrfs" ]] && {
  echo "\$MOUNTPOINT is not in a BTRFS filesystem"
  exit 1
}

/usr/local/bin/btrfs-snp \$MOUNTPOINT hourly  24 3600    ../ncp-snapshots
/usr/local/bin/btrfs-snp \$MOUNTPOINT daily    7 86400   ../ncp-snapshots
/usr/local/bin/btrfs-snp \$MOUNTPOINT weekly   4 604800  ../ncp-snapshots
/usr/local/bin/btrfs-snp \$MOUNTPOINT monthly 12 2592000 ../ncp-snapshots
EOF
  chmod 755 /etc/cron.hourly/btrfs-snp
  echo "automatic snapshots enabled"
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

