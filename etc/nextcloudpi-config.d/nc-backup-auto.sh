#!/bin/bash
# Nextcloud backups
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh nc-backup-auto.sh <IP> (<img>)
#
# See installer.sh instructions for details
#
# More at https://ownyourbits.com/2017/02/13/nextcloud-ready-raspberry-pi-image/
#


ACTIVE_=no
DESTDIR_=/media/USBdrive/ncp-backups
INCLUDEDATA_=no
COMPRESS_=no
BACKUPDAYS_=7
BACKUPLIMIT_=4
DESCRIPTION="Periodic backups"

configure()
{
  [[ $ACTIVE_ != "yes" ]] && { 
    rm /etc/cron.d/ncp-backup-auto
    echo "automatic backups disabled"
    return 0
  }

  cat > /usr/local/bin/ncp-backup-auto <<EOF
#!/bin/bash
sudo -u www-data php /var/www/nextcloud/occ maintenance:mode --on
/usr/local/bin/ncp-backup "$DESTDIR_" "$INCLUDEDATA_" "$COMPRESS_" "$BACKUPLIMIT_"
sudo -u www-data php /var/www/nextcloud/occ maintenance:mode --off
EOF
  chmod +x /usr/local/bin/ncp-backup-auto

  echo "0  3  */${BACKUPDAYS_}  *  *  root  /usr/local/bin/ncp-backup-auto" > /etc/cron.d/ncp-backup-auto
  service cron restart

  echo "automatic backups enabled"
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

