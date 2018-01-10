#!/bin/bash

# Init NextCloud database and perform initial configuration
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

ADMINUSER_=ncp
ADMINPASS_=ownyourbits
DBADMIN=ncadmin
DESCRIPTION="(Re)initiate Nextcloud to a clean configuration"

INFOTITLE="Clean NextCloud configuration"
INFO="This action will configure NextCloud to NextCloudPi defaults.

** YOUR CONFIGURATION WILL BE LOST **

"

configure()
{
  echo "Setting up a clean Nextcloud instance... wait until message 'NC init done'"

  # checks
  local REDISPASS=$( grep "^requirepass" /etc/redis/redis.conf  | cut -d' ' -f2 )
  [[ "$REDISPASS" == "" ]] && { echo "redis server without a password. Abort"; return 1; }

  ## RE-CREATE DATABASE TABLE 

  echo "Setting up database..."

  # launch mariadb if not already running
  if ! pgrep -c mysqld &>/dev/null; then
    mysqld & 
  fi

  pgrep -x mysqld &>/dev/null || { echo "mariaDB process not found"; return 1; }

  # wait for mariadb
  # TODO FIXME armbian build
  #while :; do
    #[[ -S /run/mysqld/mysqld.sock ]] && break
    #sleep 0.5
  #done
  sleep 10

  # workaround to emulate DROP USER IF EXISTS ..;)
  local DBPASSWD=$( grep password /root/.my.cnf | cut -d= -f2 )
  mysql <<EOF
DROP DATABASE IF EXISTS nextcloud;
CREATE DATABASE nextcloud
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
GRANT USAGE ON *.* TO '$DBADMIN'@'localhost' IDENTIFIED BY '$DBPASSWD';
DROP USER '$DBADMIN'@'localhost';
CREATE USER '$DBADMIN'@'localhost' IDENTIFIED BY '$DBPASSWD';
GRANT ALL PRIVILEGES ON nextcloud.* TO $DBADMIN@localhost;
EXIT
EOF

  ## INITIALIZE NEXTCLOUD

  # make sure redis is running first
  if ! pgrep -c redis-server &>/dev/null; then
    mkdir -p /var/run/redis
    chown redis /var/run/redis
    sudo -u redis redis-server /etc/redis/redis.conf &
  fi

  while :; do
    [[ -S /run/redis/redis.sock ]] && break
    sleep 0.5
  done


  echo "Setting up Nextcloud..."

  cd /var/www/nextcloud/
  rm -f config/config.php
  sudo -u www-data php occ maintenance:install --database \
    "mysql" --database-name "nextcloud"  --database-user "$DBADMIN" --database-pass \
    "$DBPASSWD" --admin-user "$ADMINUSER_" --admin-pass "$ADMINPASS_"

  # cron jobs
  sudo -u www-data php occ background:cron

  # redis cache
  sed -i '$d' config/config.php
  cat >> config/config.php <<EOF
  'memcache.local' => '\\OC\\Memcache\\Redis',
  'memcache.locking' => '\\OC\\Memcache\\Redis',
  'redis' =>
  array (
    'host' => '/var/run/redis/redis.sock',
    'port' => 0,
    'timeout' => 0.0,
    'password' => '$REDISPASS',
  ),
);
EOF

  # 4 Byte UTF8 support
  sudo -u www-data php occ config:system:set mysql.utf8mb4 --type boolean --value="true"

  # Default trusted domain ( only from nextcloudpi-config )
  test -f /.ncp-image || bash /usr/local/bin/nextcloud-domain.sh
  sudo -u www-data php occ config:system:set trusted_domains 5 --value="nextcloudpi.local"

  # email
  sudo -u www-data php occ config:system:set mail_smtpmode     --value="php"
  sudo -u www-data php occ config:system:set mail_smtpauthtype --value="LOGIN"
  sudo -u www-data php occ config:system:set mail_from_address --value="admin"
  sudo -u www-data php occ config:system:set mail_domain       --value="ownyourbits.com"

  # NCP theme
  local ID=$( grep instanceid config/config.php | awk -F "=> " '{ print $2 }' | sed "s|[,']||g" )
  [[ "$ID" == "" ]] && { echo "failed to get ID"; return 1; }
  mkdir -p data/appdata_${ID}/theming/images
  cp /usr/local/etc/logo /usr/local/etc/background data/appdata_${ID}/theming/images
  chown -R www-data:www-data data/appdata_${ID}

  mysql nextcloud <<EOF
replace into  oc_appconfig values ( 'theming', 'name'          , "NextCloudPi"             );
replace into  oc_appconfig values ( 'theming', 'slogan'        , "keep your data close"    );
replace into  oc_appconfig values ( 'theming', 'url'           , "https://ownyourbits.com" );
replace into  oc_appconfig values ( 'theming', 'logoMime'      , "image/svg+xml"           );
replace into  oc_appconfig values ( 'theming', 'backgroundMime', "image/png"               );
EOF

  # NCP notifications
  local URL=$( wget -q -O - https://api.github.com/repos/nextcloud/admin_notifications/releases | \
                grep browser_download_url | head -1 | cut -d '"' -f 4 )
  cd /var/www/nextcloud/apps
  wget "$URL" -O admin_notifications.tar.gz
  tar -xf admin_notifications.tar.gz
  rm *.tar.gz
  chown -R www-data:www-data *
  sudo -u www-data php /var/www/nextcloud/occ app:enable admin_notifications

  # other
  sudo -u www-data php /var/www/nextcloud/occ config:system:set overwriteprotocol --value=https

  echo "NC init done"
}

install(){ :; }

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
