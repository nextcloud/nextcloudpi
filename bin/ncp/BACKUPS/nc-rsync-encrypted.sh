#!/bin/bash

# Sync Nextcloud datafolder through rsync, encrypted via duplicity
#
# Copyleft 2020 by Daniel Ploeger
# 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at https://ownyourbits.com/2017/02/13/nextcloud-ready-raspberry-pi-image/
#

BASEDIR=/var/www

install()
{
  apt-get update
  apt-get install --no-install-recommends -y rsync openssh-client
  apt-get install --no-install-recommends -y duplicity
}

configure()
{
  [[ $INCLUDEDB != "yes" && $INCLUDEDATA != "yes"  ]] && { 
    echo "no sync content selected"
    return 0
  }
  sudo -u www-data php "$BASEDIR"/nextcloud/occ maintenance:mode --on

  local DATADIR
  DATADIR=$( sudo -u www-data php /var/www/nextcloud/occ config:system:get datadirectory ) || {
    echo -e "Error reading data directory. Is NextCloud running and configured?";
    return 1;
  }
  
  [[ "$INCLUDEDB" == "yes" ]] && {
    dbdestination="/$( sed 's|.*//||' <<<$DESTINATION )"/database 
    dbbackup=nextcloud-sqlbkp_$( date +"%Y%m%d" ).bak
    mysqldump --single-transaction nextcloud > /var/www/"$dbbackup"
    ( duplicity full --rsync-options="-ax --rsync-path=\"mkdir -p \"$dbdestination\" && rsync\"" --ssh-options="-p $PORTNUMBER" --encrypt-key "$GPGKEY" /var/www/"$dbbackup" rsync://"$DESTINATION"database ) || {
      echo -e "If incomplete backup sets exist in the remote folder please continue the backup manually with the command:\n\nduplicity full --rsync-options=\"-ax\" --ssh-options=\"-p $PORTNUMBER\" --encrypt-key "$GPGKEY" /var/www/"$dbbackup" rsync://"$DESTINATION"database\n";
	  sudo -u www-data php "$BASEDIR"/nextcloud/occ maintenance:mode --off;
      return 1;
	}
    rm /var/www/"$dbbackup"
  }
  [[ "$INCLUDEDATA" == "yes" ]] && {
    datadestination="/$( sed 's|.*//||' <<<$DESTINATION )"/data 
    ( duplicity full --rsync-options="-ax --rsync-path=\"mkdir -p \"$datadestination\" && rsync\"" --ssh-options="-p $PORTNUMBER" --encrypt-key "$GPGKEY" --asynchronous-upload "$DATADIR" rsync://"$DESTINATION"data ) || {
      echo -e "If incomplete backup sets exist in the remote folder please continue the backup manually with the command:\n\nduplicity full --rsync-options=\"-ax\" --ssh-options=\"-p $PORTNUMBER\" --encrypt-key "$GPGKEY" "$DATADIR" rsync://"$DESTINATION"data\n";
	  sudo -u www-data php "$BASEDIR"/nextcloud/occ maintenance:mode --off;
      return 1;
	}
  }

  sudo -u www-data php "$BASEDIR"/nextcloud/occ maintenance:mode --off
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

