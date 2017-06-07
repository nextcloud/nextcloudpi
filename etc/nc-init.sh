#!/bin/bash

# Init NextCloud database and perform initial configuration
# Tested with 2017-03-02-raspbian-jessie-lite.img
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh nc-init.sh <IP> (<img>)
#
# See installer.sh instructions for details
#
# More at https://ownyourbits.com/2017/02/13/nextcloud-ready-raspberry-pi-image/
#

ADMINUSER_=admin
DBADMIN_=ncadmin
DBPASSWD_=ownyourbits

install()
{
  # RE-CREATE DATABASE TABLE (workaround to emulate DROP USER IF EXISTS ..;)

  echo "Setting up database..."

  # wait for mariadb
  while :; do
    [[ -S /var/run/mysqld/mysqld.sock ]] && break
    sleep 0.5
  done

  mysql -u root -p$DBPASSWD_ <<EOF
DROP DATABASE IF EXISTS nextcloud;
CREATE DATABASE nextcloud;
GRANT USAGE ON *.* TO '$DBADMIN_'@'localhost' IDENTIFIED BY '$DBPASSWD_';
DROP USER '$DBADMIN_'@'localhost';
CREATE USER '$DBADMIN_'@'localhost' IDENTIFIED BY '$DBPASSWD_';
GRANT ALL PRIVILEGES ON nextcloud.* TO $DBADMIN_@localhost;
EXIT
EOF

  # INITIALIZE NEXTCLOUD

  echo "Setting up Nextcloud..."

  cd /var/www/nextcloud/
  sudo -u www-data php occ maintenance:install --database \
    "mysql" --database-name "nextcloud"  --database-user "$DBADMIN_" --database-pass \
    "$DBPASSWD_" --admin-user "$ADMINUSER_" --admin-pass "$DBPASSWD_"

  sudo -u www-data php occ background:cron
  sed -i '$i\ \ '\''memcache.local'\'' => '\''\\\\OC\\\\Memcache\\\\APCu'\'',' /var/www/nextcloud/config/config.php
}

configure(){ :; }
cleanup()  { :; }

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
