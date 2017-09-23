#!/bin/bash

#!/bin/bash
# Nextcloud restore backup
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
BASEDIR=/var/www
DBADMIN=ncadmin
DESCRIPTION="Restore a previously backuped NC instance"

INFOTITLE="Restore NextCloud backup"
INFO="This new installation will cleanup current
NextCloud instance, including files and database.

** perform backup before proceding **

You can use nc-backup"

configure()
{ 
  [ -f $BACKUPFILE_       ] || { echo -e "$BACKUPFILE_ not found"; return 1;  }
  [ -d $BASEDIR           ] || { echo -e "$BASEDIR    not found"; return 1;   }
  [ -d $BASEDIR/nextcloud ] && { echo -e "INFO: overwriting old instance"; }

  local TMPDIR="$( dirname $BACKUPFILE_ )/$( basename ${BACKUPFILE_}-tmp )"
  rm -rf "$TMPDIR" && mkdir -p "$TMPDIR"
  tar -xf "$BACKUPFILE_" -C "$TMPDIR" || return 1

  ## RESTORE FILES

  echo -e "restore files..."
  rm -rf $BASEDIR/nextcloud
  mv "$TMPDIR"/nextcloud $BASEDIR

  ## RE-CREATE DATABASE TABLE

  local DBPASSWD=$( grep password /root/.my.cnf | cut -d= -f2 )
  echo -e "restore database..."
  mysql -u root <<EOF
DROP DATABASE IF EXISTS nextcloud;
CREATE DATABASE nextcloud;
GRANT USAGE ON *.* TO '$DBADMIN'@'localhost' IDENTIFIED BY '$DBPASSWD';
DROP USER '$DBADMIN'@'localhost';
CREATE USER '$DBADMIN'@'localhost' IDENTIFIED BY '$DBPASSWD';
GRANT ALL PRIVILEGES ON nextcloud.* TO $DBADMIN@localhost;
EXIT
EOF
  [ $? -ne 0 ] && { echo -e "Error configuring nextcloud database"; return 1; }

  mysql -u root nextcloud <  "$TMPDIR"/nextcloud-sqlbkp_*.bak || { echo -e "Error restoring nextcloud database"; return 1; }

  ## RESTORE DATADIR

  cd $BASEDIR/nextcloud

  # INCLUDEDATA=yes situation

  if [[ $( ls "$TMPDIR" | wc -l ) == 2 ]]; then           
    local DATADIR=$( grep datadirectory $BASEDIR/nextcloud/config/config.php | awk '{ print $3 }' | grep -oP "[^']*[^']" | head -1 ) 
    [[ "$DATADIR" == "" ]] && { echo -e "Error reading data directory"; return 1; }
    echo -e "restore datadir to $DATADIR..."
    test -e "$DATADIR" && { 
      echo "backing up existing $DATADIR"
      mv "$DATADIR" "$DATADIR-$( date "+%m-%d-%y" )" 
    }
    mkdir -p "$( dirname "$DATADIR" )"
    mv "$TMPDIR/$( basename "$DATADIR" )" "$DATADIR"
    sudo -u www-data php occ maintenance:mode --off

  # INCLUDEDATA=no situation

  else      
    echo -e "no datadir found in backup"
    sed -i "s|'datadirectory' =>.*|'datadirectory' => '/var/www/nextcloud/data',|" config/config.php

    sudo -u www-data php occ maintenance:mode --off
    sudo -u www-data php occ files:scan --all

    # cache needs to be cleaned as of NC 12
   
    bash -c " sleep 3
              systemctl stop php7.0-fpm
              systemctl stop mysqld
              sleep 0.5
              systemctl start php7.0-fpm
              systemctl start mysqld
              " &>/dev/null &
  fi
  rm -r "$TMPDIR"

  # update NC database password to this instance
  sed -i "s|'dbpassword' =>.*|'dbpassword' => '$DBPASSWD',|" config/config.php

  # Just in case we moved the opcache dir
  sed -i "s|^opcache.file_cache=.*|opcache.file_cache=$BASEDIR/nextcloud/data/.opcache|" /etc/php/7.0/mods-available/opcache.ini
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

