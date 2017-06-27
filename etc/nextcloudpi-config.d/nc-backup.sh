#!/bin/bash
# Nextcloud backups
# Tested with 2017-03-02-raspbian-jessie-lite.img
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh nc-backup.sh <IP> (<img>)
#
# See installer.sh instructions for details
#
# More at https://ownyourbits.com/2017/02/13/nextcloud-ready-raspberry-pi-image/
#


DESTDIR_=/media/USBdrive
BASEDIR_=/var/www
DBPASSWD_=ownyourbits
DESCRIPTION="Backup this NC instance to a file"

DESTFILE=$DESTDIR_/nextcloud-bkp_`date +"%Y%m%d"`.tar 
DBBACKUP=nextcloud-sqlbkp_`date +"%Y%m%d"`.bak

configure()
{
  cd $BASEDIR_/nextcloud
  sudo -u www-data php occ maintenance:mode --on

  cd $BASEDIR_
  echo -e "backup database..."
  mysqldump -u root -p$DBPASSWD_ --single-transaction nextcloud > $DBBACKUP

  echo -e "backup files..."
  tar -cf $DESTFILE $DBBACKUP nextcloud/ && \
    echo -e "backup $DESTFILE generated" || \
    echo -e "error generating backup"
  rm $DBBACKUP

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

