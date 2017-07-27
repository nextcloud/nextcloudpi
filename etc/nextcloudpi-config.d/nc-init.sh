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
DESCRIPTION="(Re)initiate Nextcloud to a clean configuration"

show_info()
{
  whiptail --yesno \
         --backtitle "NextCloudPi configuration" \
         --title "Clean NextCloud configuration" \
"This action will configure NextCloud to NextCloudPi defaults.

** YOUR CONFIGURATION WILL BE LOST **

" \
  20 90
}

configure()
{
  local DBPASSWD=$( cat /root/.dbpass )

  ## RE-CREATE DATABASE TABLE 

  echo "Setting up database..."

  # wait for mariadb
  pgrep -x mysqld &>/dev/null || { echo "mariaDB process not found"; return 1; }

  while :; do
    [[ -S /var/run/mysqld/mysqld.sock ]] && break
    sleep 0.5
  done

  # workaround to emulate DROP USER IF EXISTS ..;)
  mysql -u root -p$DBPASSWD <<EOF
DROP DATABASE IF EXISTS nextcloud;
CREATE DATABASE nextcloud
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
GRANT USAGE ON *.* TO '$DBADMIN_'@'localhost' IDENTIFIED BY '$DBPASSWD';
DROP USER '$DBADMIN_'@'localhost';
CREATE USER '$DBADMIN_'@'localhost' IDENTIFIED BY '$DBPASSWD';
GRANT ALL PRIVILEGES ON nextcloud.* TO $DBADMIN_@localhost;
EXIT
EOF

  ## INITIALIZE NEXTCLOUD

  echo "Setting up Nextcloud..."

  cd /var/www/nextcloud/
  rm -f config/config.php
  sudo -u www-data php occ maintenance:install --database \
    "mysql" --database-name "nextcloud"  --database-user "$DBADMIN_" --database-pass \
    "$DBPASSWD" --admin-user "$ADMINUSER_" --admin-pass "$DBPASSWD"

  # cron jobs
  sudo -u www-data php occ background:cron

  # ACPu cache
  sed -i '$i\ \ '\''memcache.local'\'' => '\''\\\\OC\\\\Memcache\\\\APCu'\'',' /var/www/nextcloud/config/config.php

  # 4 Byte UTF8 support
  sudo -u www-data php occ config:system:set mysql.utf8mb4 --type boolean --value="true"

  # Default trusted domain ( only from nextcloudpi-config )
  test -f /usr/local/bin/nextcloud-domain.sh && bash /usr/local/bin/nextcloud-domain.sh
}

install(){ :; }
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
