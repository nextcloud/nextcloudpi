#!/bin/bash
# Nextcloud backups
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
INCLUDEDATA_=no
BACKUPLIMIT_=4
DESCRIPTION="Backup this NC instance to a file"

DESTFILE=$DESTDIR_/nextcloud-bkp_`date +"%Y%m%d"`.tar 
DBBACKUP=nextcloud-sqlbkp_`date +"%Y%m%d"`.bak
BASEDIR=/var/www

configure()
{
  local DATADIR
  DATADIR=$( cd $BASEDIR/nextcloud; sudo -u www-data php occ config:system:get datadirectory ) || {
    echo -e "Error reading data directory. Is NextCloud running and configured?";
    return 1;
  }

  cd $BASEDIR/nextcloud
  sudo -u www-data php occ maintenance:mode --on

  cd $BASEDIR
  echo -e "backup database..."
  mysqldump -u root --single-transaction nextcloud > $DBBACKUP

  [[ "$INCLUDEDATA_" == "yes" ]] && echo -e "backup datadir... "
  echo -e "backup files..."
  mkdir -p $DESTDIR_
  tar -cf $DESTFILE $DATAFILE $DBBACKUP nextcloud/ --exclude "nextcloud/data/*/files/*" && \
    echo -e "backup $DESTFILE generated" || \
    echo -e "error generating backup"
  rm $DBBACKUP

  [[ "$INCLUDEDATA_" == "yes" ]] && {
    tar -rf $DESTFILE -C $DATADIR/.. $( basename $DATADIR ) || \
      echo -e "error generating data backup"
  }

  # delete older backups
  [[ $BACKUPLIMIT_ != 0 ]] && {
    local NUMBKPS=$( ls $DESTDIR_/nextcloud-bkp_* | wc -l )
    [[ $NUMBKPS > $BACKUPLIMIT_ ]] && \
      ls -t $DESTDIR_/nextcloud-bkp_* | tail -$(( NUMBKPS - $BACKUPLIMIT_ )) | while read f; do
        echo -e "clean up old backup $f"
        rm $f
      done
  }

  cd $BASEDIR/nextcloud
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

