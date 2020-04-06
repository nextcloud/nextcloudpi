#!/bin/bash

# Nextcloud installation on Raspbian over LAMP base
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at https://ownyourbits.com/2017/02/13/nextcloud-ready-raspberry-pi-image/
#

DBADMIN=ncadmin
REDIS_MEM=3gb

APTINSTALL="apt-get install -y --no-install-recommends"
export DEBIAN_FRONTEND=noninteractive

install()
{
  # During build, this step is run before ncp.sh. Avoid executing twice
  [[ -f /usr/lib/systemd/system/nc-provisioning.service ]] && return 0

  source /usr/local/etc/library.sh # sets PHPVER RELEASE

  # Optional packets for Nextcloud and Apps
  apt-get update
  $APTINSTALL lbzip2 iputils-ping jq
  $APTINSTALL -t $RELEASE php-smbclient exfat-fuse exfat-utils                  # for external storage
  $APTINSTALL -t $RELEASE php${PHPVER}-exif                                     # for gallery
  $APTINSTALL -t $RELEASE php-gmp php${PHPVER}-gmp                                      # for bookmarks
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

  $APTINSTALL redis-server
  $APTINSTALL -t $RELEASE php${PHPVER}-redis

  local REDIS_CONF=/etc/redis/redis.conf
  local REDISPASS="default"
  sed -i "s|# unixsocket .*|unixsocket /var/run/redis/redis.sock|" $REDIS_CONF
  sed -i "s|# unixsocketperm .*|unixsocketperm 770|"               $REDIS_CONF
  sed -i "s|# requirepass .*|requirepass $REDISPASS|"              $REDIS_CONF
  sed -i 's|# maxmemory-policy .*|maxmemory-policy allkeys-lru|'   $REDIS_CONF
  sed -i 's|# rename-command CONFIG ""|rename-command CONFIG ""|'  $REDIS_CONF
  sed -i "s|^port.*|port 0|"                                       $REDIS_CONF
  echo "maxmemory $REDIS_MEM" >> $REDIS_CONF
  echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf

  chown redis: "$REDIS_CONF"
  usermod -a -G redis www-data

  service redis-server restart
  update-rc.d redis-server enable
  service php${PHPVER}-fpm restart

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
  ## IF BETA SELECTED ADD "pre" to DOWNLOAD PATH
  [[ "$BETA" == yes ]] && local PREFIX="pre"
    
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
  local OPCACHEDIR=/var/www/nextcloud/data/.opcache
  sed -i "s|^opcache.file_cache=.*|opcache.file_cache=$OPCACHEDIR|" /etc/php/${PHPVER}/mods-available/opcache.ini
  mkdir -p $OPCACHEDIR
  chown -R www-data:www-data $OPCACHEDIR

  ## RE-CREATE DATABASE TABLE
  # launch mariadb if not already running (for docker build)
  if ! pgrep -c mysqld &>/dev/null; then
    echo "Starting mariaDB"
    mysqld &
  fi

  # wait for mariadb
  pgrep -x mysqld &>/dev/null || echo "mariaDB process not found"

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
  cat > /etc/apache2/sites-available/nextcloud.conf <<'EOF'
<IfModule mod_ssl.c>
  <VirtualHost _default_:443>
    DocumentRoot /var/www/nextcloud
    CustomLog /var/log/apache2/nc-access.log combined
    ErrorLog  /var/log/apache2/nc-error.log
    SSLEngine on
    SSLCertificateFile      /etc/ssl/certs/ssl-cert-snakeoil.pem
    SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key
  </VirtualHost>
  <Directory /var/www/nextcloud/>
    Options +FollowSymlinks
    AllowOverride All
    <IfModule mod_dav.c>
      Dav off
    </IfModule>
    LimitRequestBody 0
    SSLRenegBufferSize 10486000
  </Directory>
</IfModule>
EOF
  a2ensite nextcloud

  cat > /etc/apache2/sites-available/000-default.conf <<'EOF'
<VirtualHost _default_:80>
  DocumentRoot /var/www/nextcloud
  <IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteCond %{HTTPS} !=on
    RewriteRule ^/?(.*) https://%{SERVER_NAME}/$1 [R,L]
  </IfModule>
</VirtualHost>
EOF

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
  echo "*/15  *  *  *  * php -f /var/www/nextcloud/cron.php" > /tmp/crontab_http
  crontab -u www-data /tmp/crontab_http
  rm /tmp/crontab_http

  echo "Don't forget to run nc-init"
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

