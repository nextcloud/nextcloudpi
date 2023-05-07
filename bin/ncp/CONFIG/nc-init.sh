#!/bin/bash

# Init NextCloud database and perform initial configuration
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at https://ownyourbits.com/2017/02/13/nextcloud-ready-raspberry-pi-image/
#

DBADMIN=ncadmin

configure()
{
  echo "Setting up a clean Nextcloud instance... wait until message 'NC init done'"

  # checks
  local REDISPASS=$( grep "^requirepass" /etc/redis/redis.conf  | cut -d' ' -f2 )
  [[ "$REDISPASS" == "" ]] && { echo "redis server without a password. Abort"; return 1; }

  ## RE-CREATE DATABASE TABLE

  echo "Setting up database..."

  # launch mariadb if not already running
  if ! [[ -f /run/mysqld/mysqld.pid ]]; then
    echo "Starting mariaDB"
    mysqld &
    local db_pid=$!
  fi

  # wait for mariadb
  while :; do
    [[ -S /run/mysqld/mysqld.sock ]] && break
    sleep 0.5
  done
  sleep 1

  # workaround to emulate DROP USER IF EXISTS ..;)
  local DBPASSWD=$( grep password /root/.my.cnf | sed 's|password=||' )
  mysql <<EOF
DROP DATABASE IF EXISTS nextcloud;
CREATE DATABASE nextcloud
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_general_ci;
GRANT USAGE ON *.* TO '$DBADMIN'@'localhost' IDENTIFIED BY '$DBPASSWD';
DROP USER '$DBADMIN'@'localhost';
CREATE USER '$DBADMIN'@'localhost' IDENTIFIED BY '$DBPASSWD';
GRANT ALL PRIVILEGES ON nextcloud.* TO $DBADMIN@localhost;
EXIT
EOF

  ## INITIALIZE NEXTCLOUD

  # make sure redis is running first
  systemctl start redis
  docker exec -it ncp-redis redis-cli -a "${REDISPASS}" ping | grep PONG


  echo "Setting up Nextcloud..."

  cd /var/www/nextcloud/
  rm -f config/config.php
  ncc maintenance:install --database \
    "mysql" --database-name "nextcloud"  --database-user "$DBADMIN" --database-pass \
    "$DBPASSWD" --admin-user "$ADMINUSER" --admin-pass "$ADMINPASS"

  # cron jobs
  ncc background:cron

  # redis cache
  sed -i '$d' config/config.php
  cat >> config/config.php <<EOF
  'memcache.local' => '\\OC\\Memcache\\Redis',
  'memcache.locking' => '\\OC\\Memcache\\Redis',
  'redis' =>
  array (
    'host' => '127.0.0.1',
    'port' => 6379,
    'timeout' => 5.0,
    'password' => '$REDISPASS',
  ),
);
EOF

  # tmp upload dir
  local UPLOADTMPDIR=/var/www/nextcloud/data/tmp
  mkdir -p "$UPLOADTMPDIR"
  chown www-data:www-data "$UPLOADTMPDIR"
  ncc config:system:set tempdirectory --value "$UPLOADTMPDIR"
  sed -i "s|^;\?upload_tmp_dir =.*$|upload_tmp_dir = $UPLOADTMPDIR|" /etc/php/${PHPVER}/cli/php.ini
  sed -i "s|^;\?upload_tmp_dir =.*$|upload_tmp_dir = $UPLOADTMPDIR|" /etc/php/${PHPVER}/fpm/php.ini
  sed -i "s|^;\?sys_temp_dir =.*$|sys_temp_dir = $UPLOADTMPDIR|"     /etc/php/${PHPVER}/fpm/php.ini

  # 4 Byte UTF8 support
  ncc config:system:set mysql.utf8mb4 --type boolean --value="true"

  ncc config:system:set trusted_domains 7 --value="nextcloudpi"
  ncc config:system:set trusted_domains 5 --value="nextcloudpi.local"
  ncc config:system:set trusted_domains 8 --value="nextcloudpi.lan"
  ncc config:system:set trusted_domains 3 --value="nextcloudpi.lan"

  # email
  ncc config:system:set mail_smtpmode     --value="sendmail"
  ncc config:system:set mail_smtpauthtype --value="LOGIN"
  ncc config:system:set mail_from_address --value="admin"
  ncc config:system:set mail_domain       --value="ownyourbits.com"

  # Fix NCP theme
  [[ -e /usr/local/etc/logo ]] && {
    local ID=$( grep instanceid config/config.php | awk -F "=> " '{ print $2 }' | sed "s|[,']||g" )
    [[ "$ID" == "" ]] && { echo "failed to get ID"; return 1; }
    local theming_base_path="data/appdata_${ID}/theming/global/images"
    mkdir -p "${theming_base_path}"
    cp /usr/local/etc/background "${theming_base_path}/"
    cp /usr/local/etc/logo "${theming_base_path}/logo"
    cp /usr/local/etc/logo "${theming_base_path}/logoheader"
    chown -R www-data:www-data "data/appdata_${ID}"
  }

  mysql nextcloud <<EOF
replace into  oc_appconfig values ( 'theming', 'name'          , "NextCloudPi"             );
replace into  oc_appconfig values ( 'theming', 'slogan'        , "keep your data close"    );
replace into  oc_appconfig values ( 'theming', 'url'           , "https://ownyourbits.com" );
replace into  oc_appconfig values ( 'theming', 'logoMime'      , "image/svg+xml"           );
replace into  oc_appconfig values ( 'theming', 'backgroundMime', "image/png"               );
EOF

  # NCP app
  cp -r /var/www/ncp-app /var/www/nextcloud/apps/nextcloudpi
  chown -R www-data:     /var/www/nextcloud/apps/nextcloudpi
  ncc app:enable nextcloudpi

  # enable some apps by default
  ncc app:install calendar
  ncc app:enable  calendar
  ncc app:install contacts
  ncc app:enable  contacts
  ncc app:install notes
  ncc app:enable  notes
  ncc app:install tasks
  ncc app:enable  tasks

  # we handle this ourselves
  ncc app:disable updatenotification

  # News dropped support for 32-bit -> https://github.com/nextcloud/news/issues/1423
  if ! [[ "$ARCH" =~ armv7 ]]; then
    ncc app:install news
    ncc app:enable  news
  fi

  # ncp-previewgenerator
  local ncver
  ncver="$(ncc status 2>/dev/null | grep "version:" | awk '{ print $3 }')"
  if is_more_recent_than "21.0.0" "${ncver}"; then
    local ncprev=/var/www/ncp-previewgenerator/ncp-previewgenerator-nc20
  else
    ncc app:install notify_push
    ncc app:enable  notify_push
    test -f /.ncp-image || start_notify_push # don't start during build
    local ncprev=/var/www/ncp-previewgenerator/ncp-previewgenerator-nc21
  fi
  ln -snf "${ncprev}" /var/www/nextcloud/apps/previewgenerator
  chown -R www-data: /var/www/nextcloud/apps/previewgenerator
  ncc app:enable previewgenerator

  # previews
  ncc config:app:set previewgenerator squareSizes --value="32 256"
  ncc config:app:set previewgenerator widthSizes  --value="256 384"
  ncc config:app:set previewgenerator heightSizes --value="256"
  ncc config:system:set preview_max_x --value 2048
  ncc config:system:set preview_max_y --value 2048
  ncc config:system:set jpeg_quality --value 60
  ncc config:app:set preview jpeg_quality --value="60"

  # other
  ncc config:system:set overwriteprotocol --value=https
  ncc config:system:set overwrite.cli.url --value="https://nextcloudpi/"

  # bash completion for ncc
  apt_install bash-completion
  ncc _completion -g --shell-type bash -p ncc | sed 's|/var/www/nextcloud/occ|ncc|g' > /usr/share/bash-completion/completions/ncp
  echo ". /etc/bash_completion" >> /etc/bash.bashrc
  echo ". /usr/share/bash-completion/completions/ncp" >> /etc/bash.bashrc

  # TODO temporary workaround for https://github.com/nextcloud/server/pull/13358
  ncc -n db:convert-filecache-bigint
  ncc db:add-missing-indices

  # Default trusted domain (only from ncp-config)
  test -f /usr/local/bin/nextcloud-domain.sh && {
    test -f /.ncp-image || bash /usr/local/bin/nextcloud-domain.sh
  }

  # dettach mysql during the build
  if [[ "${db_pid}" != "" ]]; then
    echo "Shutting down mariaDB (${db_pid})"
    mysqladmin -u root shutdown
    wait "${db_pid}"
  fi

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
