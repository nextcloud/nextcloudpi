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


DESTDIR_=/media/USBdrive/ncp-backups
INCLUDEDATA_=no
COMPRESS_=no
BACKUPLIMIT_=4
DESCRIPTION="Backup this NC instance to a file"

install()
{
  cat > /usr/local/bin/ncp-backup <<'EOF'
#!/bin/bash

DESTDIR="${1:-/media/USBdrive/ncp-backups}"
INCLUDEDATA="${2:-no}"
COMPRESS="${3:-no}"
BACKUPLIMIT="${4:-4}"

DESTFILE="$DESTDIR"/nextcloud-bkp_$( date +"%Y%m%d" ).tar 
DBBACKUP=nextcloud-sqlbkp_$( date +"%Y%m%d" ).bak
BASEDIR=/var/www

DATADIR=$( cd "$BASEDIR"/nextcloud; sudo -u www-data php occ config:system:get datadirectory ) || {
  echo "Error reading data directory. Is NextCloud running and configured?";
  exit 1;
}

echo "check free space..."
SIZE=$( du -s "$DATADIR" |           awk '{ print $1 }' )
FREE=$( df    "$DESTDIR" | tail -1 | awk '{ print $4 }' )

[ $SIZE -ge $FREE ] && { 
  echo "free space check failed. Need $( du -sh "$DATADIR" | awk '{ print $1 }' )";
  exit 1; 
}

# delete older backups
[[ $BACKUPLIMIT != 0 ]] && {
  NUMBKPS=$( ls "$DESTDIR"/nextcloud-bkp_* 2>/dev/null | wc -l )
  [[ $NUMBKPS -ge $BACKUPLIMIT ]] && \
    ls -t $DESTDIR/nextcloud-bkp_* | tail -$(( NUMBKPS - BACKUPLIMIT + 1 )) | while read -r f; do
      echo "clean up old backup $f"
      rm "$f"
    done
}

# database
cd "$BASEDIR" || exit 1
echo "backup database..."
mysqldump -u root --single-transaction nextcloud > "$DBBACKUP"

# files
echo "backup base files..."
mkdir -p "$DESTDIR"
tar --exclude "nextcloud/data/*/files/*" \
    --exclude "nextcloud/data/.opcache" \
    --exclude "nextcloud/data/{access,error,nextcloud}.log" \
    --exclude "nextcloud/data/access.log" \
    -cf "$DESTFILE" "$DBBACKUP" nextcloud/ \
  || {
        echo "error generating backup"
        exit 1
      }
rm "$DBBACKUP"

[[ "$INCLUDEDATA" == "yes" ]] && {
  echo "backup data files..."
  tar --exclude "data/.opcache" \
      --exclude "data/{access,error,nextcloud}.log" \
      --exclude "data/access.log" \
      -rf "$DESTFILE" -C "$DATADIR"/.. "$( basename "$DATADIR" )" \
  || {
        echo "error generating backup"
        exit 1
      }
} 

[[ "$COMPRESS" == "yes" ]] && {
  echo "compressing backup file..."
  tar -czf "${DESTFILE}.gz" -C "$( dirname "$DESTFILE" )" "$( basename "$DESTFILE" )"
  rm "$DESTFILE"
  DESTFILE="${DESTFILE}.gz"
}

echo "backup $DESTFILE generated"
EOF
  chmod +x /usr/local/bin/ncp-backup
}

configure()
{
  sudo -u www-data php /var/www/nextcloud/occ maintenance:mode --on

  ncp-backup "$DESTDIR_" "$INCLUDEDATA_" "$COMPRESS_" "$BACKUPLIMIT_"
  local RET=$?

  sudo -u www-data php /var/www/nextcloud/occ maintenance:mode --off

  return $RET
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

