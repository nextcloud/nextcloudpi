#!/bin/bash

#!/bin/bash
# Nextcloud restore backup
# Tested with 2017-03-02-raspbian-jessie-lite.img
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh nc-restore.sh <IP> (<img>)
#
# See installer.sh instructions for details
#
# More at https://ownyourbits.com/2017/02/13/nextcloud-ready-raspberry-pi-image/
#


BACKUPFILE_=/media/USBdrive/nextcloud-bkp_xxxxxxxx.tar
BASEDIR_=/var/www
DBADMIN_=ncadmin
DESCRIPTION="Restore a previously backuped NC instance"

show_info()
{
  [ -d /var/www/nextcloud ] && \
    whiptail --yesno \
           --backtitle "NextCloudPi configuration" \
           --title "Restore NextCloud backup" \
"This new installation will cleanup current
NextCloud instance, including files and database.

** perform backup before proceding **

You can use nc-backup " \
  20 90
}

configure()
{ 
  local DBPASSWD=$( cat /root/.dbpass )

  [ -f $BACKUPFILE_        ] || { echo -e "$BACKUPFILE_ not found"; return 1;  }
  [ -d $BASEDIR_           ] || { echo -e "$BASEDIR_    not found"; return 1;  }
  [ -d $BASEDIR_/nextcloud ] && { echo -e "WARNING: overwriting old instance"; }

  cd $BASEDIR_/nextcloud
  sudo -u www-data php occ maintenance:mode --on

  # RESTORE FILES
  echo -e "restore files..."
  cd $BASEDIR_
  rm -rf nextcloud
  tar -xf $BACKUPFILE_ || return 1

  # RE-CREATE DATABASE TABLE
  echo -e "restore database..."
  mysql -u root -p$DBPASSWD <<EOF
DROP DATABASE IF EXISTS nextcloud;
CREATE DATABASE nextcloud;
GRANT USAGE ON *.* TO '$DBADMIN_'@'localhost' IDENTIFIED BY '$DBPASSWD';
DROP USER '$DBADMIN_'@'localhost';
CREATE USER '$DBADMIN_'@'localhost' IDENTIFIED BY '$DBPASSWD';
GRANT ALL PRIVILEGES ON nextcloud.* TO $DBADMIN_@localhost;
EXIT
EOF
  [ $? -ne 0 ] && { echo -e "error configuring nextcloud database"; return 1; }

  mysql -u root -p$DBPASSWD nextcloud <  nextcloud-sqlbkp_*.bak || { echo -e "error restoring nextcloud database"; return 1; }

  cd $BASEDIR_/nextcloud
  sudo -u www-data php occ maintenance:mode --off
}

install() { :; }
cleanup() { :; }

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

