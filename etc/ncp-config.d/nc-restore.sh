#!/bin/bash

#!/bin/bash
# Nextcloud restore backup
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at https://ownyourbits.com/2017/02/13/nextcloud-ready-raspberry-pi-image/
#


BACKUPFILE_=/media/USBdrive/nextcloud-bkp_xxxxxxxx.tar
DESCRIPTION="Restore a previously backuped NC instance"

INFOTITLE="Restore NextCloud backup"
INFO="This new installation will cleanup current
NextCloud instance, including files and database.

** perform backup before proceding **

You can use nc-backup"

install()
{ 
  cat > /usr/local/bin/ncp-restore <<'EOF'
#!/bin/bash
set -eE

BACKUPFILE="$1"

DBADMIN=ncadmin
DBPASSWD="$( grep password /root/.my.cnf | sed 's|password=||' )"

DIR="$( cd "$( dirname "$BACKUPFILE" )" &>/dev/null && pwd )" #abspath

[[ -f /.docker-image ]] && NCDIR=/data/app || NCDIR=/var/www/nextcloud

[[ $# -eq 0           ]] && { echo "missing first argument"         ; exit 1; }
[[ -f "$BACKUPFILE"   ]] || { echo "$BACKUPFILE not found"          ; exit 1; }
[[ "$DIR" =~ "$NCDIR" ]] && { echo "Refusing to restore from $NCDIR"; exit 1; }

TMPDIR="$( mktemp -d "$( dirname "$BACKUPFILE" )"/ncp-restore.XXXXXX )" || { echo "Failed to create temp dir" >&2; exit 1; }
TMPDIR="$( cd "$TMPDIR" &>/dev/null && pwd )" || { echo "$TMPDIR not found"; exit 1; } #abspath
cleanup(){  local RET=$?; echo "Cleanup..."; rm -rf "${TMPDIR}"; trap "" EXIT; exit $RET; }
trap cleanup INT TERM HUP ERR EXIT
rm -rf "$TMPDIR" && mkdir -p "$TMPDIR"

# EXTRACT FILES
[[ "$BACKUPFILE" =~ ".tar.gz" ]] && COMPRESSED=1 || COMPRESSED=0
[[ "$COMPRESSED" == "1" ]] && {
  echo "decompressing backup file $BACKUPFILE..."
  tar -xzf "$BACKUPFILE" -C "$TMPDIR" || exit 1
  BACKUPFILE="$( ls "$TMPDIR"/*.tar 2>/dev/null )"
  [[ -f "$BACKUPFILE" ]] || { echo "$BACKUPFILE not found"; exit 1; }
}

echo "extracting backup file $BACKUPFILE..."
tar -xf "$BACKUPFILE" -C "$TMPDIR" || exit 1

## SANITY CHECKS
[[ -d "$TMPDIR"/nextcloud ]] && [[ -f "$( ls "$TMPDIR"/nextcloud-sqlbkp_*.bak 2>/dev/null )" ]] || {
  echo "invalid backup file. Abort"
  exit 1
}

## RESTORE FILES

echo "restore files..."
rm -rf "$NCDIR"
mv -T "$TMPDIR"/nextcloud "$NCDIR" || { echo "Error restoring base files"; exit 1; }

# update NC database password to this instance
sed -i "s|'dbpassword' =>.*|'dbpassword' => '$DBPASSWD',|" /var/www/nextcloud/config/config.php

# update redis credentials
REDISPASS="$( grep "^requirepass" /etc/redis/redis.conf | cut -f2 -d' ' )"
[[ "$REDISPASS" != "" ]] && \
  sed -i "s|'password'.*|'password' => '$REDISPASS',|" /var/www/nextcloud/config/config.php
service redis-server restart

## RE-CREATE DATABASE TABLE

echo "restore database..."
mysql -u root <<EOFMYSQL
DROP DATABASE IF EXISTS nextcloud;
CREATE DATABASE nextcloud;
GRANT USAGE ON *.* TO '$DBADMIN'@'localhost' IDENTIFIED BY '$DBPASSWD';
DROP USER '$DBADMIN'@'localhost';
CREATE USER '$DBADMIN'@'localhost' IDENTIFIED BY '$DBPASSWD';
GRANT ALL PRIVILEGES ON nextcloud.* TO $DBADMIN@localhost;
EXIT
EOFMYSQL
[ $? -ne 0 ] && { echo "Error configuring nextcloud database"; exit 1; }

mysql -u root nextcloud <  "$TMPDIR"/nextcloud-sqlbkp_*.bak || { echo "Error restoring nextcloud database"; exit 1; }

## RESTORE DATADIR

cd "$NCDIR"

### INCLUDEDATA=yes situation

NUMFILES=$(( 2 + COMPRESSED ))
if [[ $( ls "$TMPDIR" | wc -l ) -eq $NUMFILES ]]; then

  DATADIR=$( grep datadirectory "$NCDIR"/config/config.php | awk '{ print $3 }' | grep -oP "[^']*[^']" | head -1 ) 
  [[ "$DATADIR" == "" ]] && { echo "Error reading data directory"; exit 1; }

  echo "restore datadir to $DATADIR..."

  [[ -e "$DATADIR" ]] && { 
    echo "backing up existing $DATADIR"
    mv "$DATADIR" "$DATADIR-$( date "+%m-%d-%y" )" || exit 1
  }

  mkdir -p "$DATADIR"
  [[ "$( stat -fc%T "$DATADIR" )" == "btrfs" ]] && {
    rmdir "$DATADIR"                  || exit 1
    btrfs subvolume create "$DATADIR" || exit 1
  }
  chown www-data:www-data "$DATADIR"
  TMPDATA="$TMPDIR/$( basename "$DATADIR" )"
  mv "$TMPDATA"/* "$TMPDATA"/.[!.]* "$DATADIR" || exit 1
  rmdir "$TMPDATA"                             || exit 1

  sudo -u www-data php occ maintenance:mode --off

### INCLUDEDATA=no situation

else      
  echo "no datadir found in backup"
  DATADIR="$NCDIR"/data

  sudo -u www-data php occ maintenance:mode --off
  sudo -u www-data php occ files:scan --all

  # cache needs to be cleaned as of NC 12
  NEED_RESTART=1
fi

# Just in case we moved the opcache dir
sed -i "s|^opcache.file_cache=.*|opcache.file_cache=$DATADIR/.opcache|" /etc/php/7.0/mods-available/opcache.ini

# tmp upload dir
mkdir -p "$DATADIR/tmp" 
chown www-data:www-data "$DATADIR/tmp"
sed -i "s|^;\?upload_tmp_dir =.*$|upload_tmp_dir = $DATADIR/tmp|" /etc/php/7.0/cli/php.ini
sed -i "s|^;\?upload_tmp_dir =.*$|upload_tmp_dir = $DATADIR/tmp|" /etc/php/7.0/fpm/php.ini
sed -i "s|^;\?sys_temp_dir =.*$|sys_temp_dir = $DATADIR/tmp|"     /etc/php/7.0/fpm/php.ini

# update fail2ban logpath
[[ ! -f /.docker-image ]] && {
  sed -i "s|logpath  =.*|logpath  = $DATADIR/nextcloud.log|" /etc/fail2ban/jail.conf
  pgrep fail2ban &>/dev/null && service fail2ban restart
}

# refresh nextcloud trusted domains
bash /usr/local/bin/nextcloud-domain.sh

# restart PHP if needed
[[ "$NEED_RESTART" == "1" ]] && \
  bash -c " sleep 3
            service php7.0-fpm stop
            service mysql      stop
            sleep 0.5
            service php7.0-fpm start
            service mysql      start
            " &>/dev/null &
EOF
  chmod +x /usr/local/bin/ncp-restore
}

configure()
{
  ncp-restore "$BACKUPFILE_"
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

