#!/bin/bash

# Nextcloud installation on Raspbian over LAMP base
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at https://ownyourbits.com/2017/02/13/nextcloud-ready-raspberry-pi-image/
#

DBADMIN=ncadmin

APTINSTALL="apt-get install -y --no-install-recommends"
export DEBIAN_FRONTEND=noninteractive

tmpl_max_transfer_time()
{
  find_app_param nc-nextcloud MAXTRANSFERTIME
}

install()
{
  # During build, this step is run before ncp.sh. Avoid executing twice
  [[ -f /usr/lib/systemd/system/nc-provisioning.service ]] && return 0

  # Optional packets for Nextcloud and Apps
  apt-get update
  $APTINSTALL lbzip2 iputils-ping jq wget
  # NOTE: php-smbclient in sury but not in Debian sources, we'll use the binary version
  # https://docs.nextcloud.com/server/latest/admin_manual/configuration_files/external_storage/smb.html
  $APTINSTALL -t $RELEASE smbclient exfat-fuse exfat-utils                      # for external storage
  $APTINSTALL -t $RELEASE exfat-fuse exfat-utils                                # for external storage
  $APTINSTALL -t $RELEASE php${PHPVER}-exif                                     # for gallery
  $APTINSTALL -t $RELEASE php${PHPVER}-bcmath                                   # for LDAP
  $APTINSTALL -t $RELEASE php${PHPVER}-gmp                                      # for bookmarks
  #$APTINSTALL -t imagemagick php${PHPVER}-imagick ghostscript   # for gallery


  # POSTFIX
  $APTINSTALL postfix || {
    # [armbian] workaround for bug - https://bugs.launchpad.net/ubuntu/+source/postfix/+bug/1531299
    echo "[NCP] Please, ignore the previous postfix installation error ..."
    mv /usr/bin/newaliases /
    ln -s /bin/true /usr/bin/newaliases
    $APTINSTALL postfix
    rm /usr/bin/newaliases
    mv /newaliases /usr/bin/newaliases
  }

  # $APTINSTALL redis-server
  $APTINSTALL -t $RELEASE php${PHPVER}-redis

  local REDIS_CONF=/etc/redis/redis.conf
  mkdir -p "$(dirname "$REDIS_CONF")"
  install_template redis.conf.sh "$REDIS_CONF" --defaults
  install_template systemd/redis.service.sh /etc/systemd/system/redis.service --defaults
  #systemctl unmask redis.service
#  sed -i "s|# unixsocket .*|unixsocket /var/run/redis/redis.sock|" $REDIS_CONF
#  sed -i "s|# unixsocketperm .*|unixsocketperm 770|"               $REDIS_CONF
#  sed -i "s|# requirepass .*|requirepass $REDISPASS|"              $REDIS_CONF
#  sed -i 's|# maxmemory-policy .*|maxmemory-policy allkeys-lru|'   $REDIS_CONF
#  sed -i 's|# rename-command CONFIG ""|rename-command CONFIG ""|'  $REDIS_CONF
#  sed -i "s|^port.*|port 0|"                                       $REDIS_CONF
#  echo "maxmemory $REDIS_MEM" >> $REDIS_CONF

  echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf

#  if is_lxc; then
#    # Otherwise it fails to start in Buster LXC container
#    mkdir -p /etc/systemd/system/redis-server.service.d
#    cat > /etc/systemd/system/redis-server.service.d/lxc_fix.conf <<'EOF'
#[Service]
#ReadOnlyDirectories=
#EOF
#    systemctl daemon-reload
#  fi

#  chown redis: "$REDIS_CONF"
#  usermod -a -G redis www-data

  systemctl enable --now redis
#  service redis-server restart
#  update-rc.d redis-server enable
  clear_opcache

  # service to randomize passwords on first boot
  mkdir -p /usr/lib/systemd/system
  cat > /usr/lib/systemd/system/nc-provisioning.service <<'EOF'
[Unit]
Description=Randomize passwords on first boot
Requires=network.target
After=mysql.service redis.service

[Service]
ExecStart=/bin/bash /usr/local/bin/ncp-provisioning.sh

[Install]
WantedBy=multi-user.target
EOF
  [[ "$DOCKERBUILD" != 1 ]] && systemctl enable nc-provisioning
  return 0
}

configure()
{
  ## DOWNLOAD AND (OVER)WRITE NEXTCLOUD
  cd /var/www/

  local URL="https://download.nextcloud.com/server/${PREFIX}releases/nextcloud-$VER.tar.bz2"
  echo "Downloading Nextcloud $VER..."
  wget -q "$URL" -O nextcloud.tar.bz2 || {
    echo "couldn't download $URL"
    return 1
  }
  rm -rf nextcloud

  echo "Installing  Nextcloud $VER..."
  tar -xf nextcloud.tar.bz2
  rm nextcloud.tar.bz2

  ## CONFIGURE FILE PERMISSIONS
  local ocpath='/var/www/nextcloud'
  local htuser='www-data'
  local htgroup='www-data'
  local rootuser='root'

  printf "Creating possible missing Directories\n"
  mkdir -p $ocpath/data
  mkdir -p $ocpath/updater

  printf "chmod Files and Directories\n"
  find ${ocpath}/ -type f -print0 | xargs -0 chmod 0640
  find ${ocpath}/ -type d -print0 | xargs -0 chmod 0750

  printf "chown Directories\n"

  chown -R ${htuser}:${htgroup} ${ocpath}/
  chown -R ${htuser}:${htgroup} ${ocpath}/apps/
  chown -R ${htuser}:${htgroup} ${ocpath}/config/
  chown -R ${htuser}:${htgroup} ${ocpath}/data/
  chown -R ${htuser}:${htgroup} ${ocpath}/themes/
  chown -R ${htuser}:${htgroup} ${ocpath}/updater/

  chmod +x ${ocpath}/occ

  printf "chmod/chown .htaccess\n"
  if [ -f ${ocpath}/.htaccess ]; then
    chmod 0644 ${ocpath}/.htaccess
    chown ${htuser}:${htgroup} ${ocpath}/.htaccess
  fi
  if [ -f ${ocpath}/data/.htaccess ]; then
    chmod 0644 ${ocpath}/data/.htaccess
    chown ${htuser}:${htgroup} ${ocpath}/data/.htaccess
  fi

  # create and configure opcache dir
  local OPCACHEDIR="$(
    # shellcheck disable=SC2015
    [ -f "${BINDIR}/CONFIG/nc-datadir.sh" ] && { source "${BINDIR}/CONFIG/nc-datadir.sh"; tmpl_opcache_dir; } || true
  )"
  if [[ -z "${OPCACHEDIR}" ]]
  then
    install_template "php/opcache.ini.sh" "/etc/php/${PHPVER}/mods-available/opcache.ini" --defaults
  else
    mkdir -p "$OPCACHEDIR"
    chown -R www-data:www-data "$OPCACHEDIR"
    install_template "php/opcache.ini.sh" "/etc/php/${PHPVER}/mods-available/opcache.ini"
  fi

  ## RE-CREATE DATABASE TABLE
  # launch mariadb if not already running (for docker build)
  if ! [[ -f /run/mysqld/mysqld.pid ]]; then
    echo "Starting mariaDB"
    mysqld &
    local db_pid=$!
  fi

  while :; do
    [[ -S /var/run/mysqld/mysqld.sock ]] && break
    sleep 0.5
  done

  echo "Setting up database..."

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

## SET APACHE VHOST
  echo "Setting up Apache..."
  install_template nextcloud.conf.sh /etc/apache2/sites-available/nextcloud.conf --allow-fallback || {
      echo "ERROR: Parsing template failed. Nextcloud will not work."
      exit 1
  }
  a2ensite nextcloud

  cat > /etc/apache2/sites-available/000-default.conf <<'EOF'
<VirtualHost _default_:80>
  DocumentRoot /var/www/nextcloud
  <IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteRule ^.well-known/acme-challenge/ - [L]
    RewriteCond %{HTTPS} !=on
    RewriteRule ^/?(.*) https://%{SERVER_NAME}/$1 [R,L]
  </IfModule>
  <Directory /var/www/nextcloud/>
    Options +FollowSymlinks
    AllowOverride All
    <IfModule mod_dav.c>
      Dav off
    </IfModule>
    LimitRequestBody 0
  </Directory>
</VirtualHost>
EOF

  # for notify_push app in NC21
  a2enmod proxy proxy_http proxy_wstunnel

  arch="$(uname -m)"
  [[ "${arch}" =~ "armv7" ]] && arch="armv7"
  install_template systemd/notify_push.service.sh /etc/systemd/system/notify_push.service
  [[ -f /.docker-image ]] || systemctl enable notify_push

  # some added security
  sed -i 's|^ServerSignature .*|ServerSignature Off|' /etc/apache2/conf-enabled/security.conf
  sed -i 's|^ServerTokens .*|ServerTokens Prod|'      /etc/apache2/conf-enabled/security.conf

  echo "Setting up system..."

  ## SET LIMITS
  cat > /etc/php/${PHPVER}/fpm/conf.d/90-ncp.ini <<EOF
; disable .user.ini files for performance and workaround NC update bugs
user_ini.filename =

; from Nextcloud .user.ini
upload_max_filesize=$MAXFILESIZE
post_max_size=$MAXFILESIZE
memory_limit=$MEMORYLIMIT
mbstring.func_overload=0
always_populate_raw_post_data=-1
default_charset='UTF-8'
output_buffering=0

; slow transfers will be killed after this time
max_execution_time=$MAXTRANSFERTIME
max_input_time=$MAXTRANSFERTIME
EOF

  ## SET CRON
  echo "*/5  *  *  *  * php -f /var/www/nextcloud/cron.php" > /tmp/crontab_http
  crontab -u www-data /tmp/crontab_http
  rm /tmp/crontab_http

  # dettach mysql during the build
  if [[ "${db_pid}" != "" ]]; then
    echo "Shutting down mariaDB (${db_pid})"
    mysqladmin -u root shutdown
    wait "${db_pid}"
  fi
  echo "Don't forget to run nc-init"
}


install_() {
  apt-get update
  $APTINSTALL lbzip2 iputils-ping jq wget
  $APTINSTALL -t $RELEASE smbclient exfat-fuse exfat-utils                      # for external storage
  $APTINSTALL -t $RELEASE exfat-fuse exfat-utils                                # for external storage

  # Setup Nextcloud via docker
  install_docker
  install_template "svc/nextcloud/env.sh" "/usr/local/etc/svc/nextcloud/.env" --defaults
  install_template "systemd/ncp-nextcloud.service.sh" "/etc/systemd/system/ncp-nextcloud.service" --defaults
  systemctl daemon-reload

  # TODO: Is this really required on the host?
  # POSTFIX
  $APTINSTALL postfix || {
    # [armbian] workaround for bug - https://bugs.launchpad.net/ubuntu/+source/postfix/+bug/1531299
    echo "[NCP] Please, ignore the previous postfix installation error ..."
    mv /usr/bin/newaliases /
    ln -s /bin/true /usr/bin/newaliases
    $APTINSTALL postfix
    rm /usr/bin/newaliases
    mv /newaliases /usr/bin/newaliases
  }

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

