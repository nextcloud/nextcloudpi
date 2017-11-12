#!/bin/bash

# Nextcloud installation on Raspbian over LAMP base
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh nc-nextcloud <IP> (<img>)
#
# See installer.sh instructions for details
#
# More at https://ownyourbits.com/2017/02/13/nextcloud-ready-raspberry-pi-image/
#

VER_=12.0.3
MAXFILESIZE_=2G
MEMORYLIMIT_=768M
MAXTRANSFERTIME_=3600
DBADMIN=ncadmin
REDIS_MEM=3gb
DESCRIPTION="Install any NextCloud version"

APTINSTALL="apt-get install -y --no-install-recommends"
export DEBIAN_FRONTEND=noninteractive

[ -d /var/www/nextcloud ] && {                        # don't show this during image build
INFOTITLE="NextCloud installation"
INFO="This new installation will cleanup current
NextCloud instance, including files and database.

You can later use nc-init to configure to NextCloudPi defaults

** perform backup before proceding **

You can use nc-backup "
}

install()
{
  # Optional packets for Nextcloud and Apps
  apt-get update
  $APTINSTALL -o "Dpkg::Options::=--force-confold" php-smbclient 
  $APTINSTALL postfix lbzip2 iputils-ping
 
  # REDIS
  $APTINSTALL redis-server php7.0-redis

  local REDIS_CONF=/etc/redis/redis.conf
  sed -i "s|# unixsocket .*|unixsocket /var/run/redis/redis.sock|" $REDIS_CONF
  sed -i "s|# unixsocketperm .*|unixsocketperm 770|"               $REDIS_CONF
  sed -i "s|^port.*|port 0|"                                       $REDIS_CONF
  echo "maxmemory ${REDIS_MEM}" >> $REDIS_CONF
  echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf

  sudo usermod -a -G redis www-data

  [[ "$DOCKERBUILD" != 1 ]] && systemctl restart redis-server
  [[ "$DOCKERBUILD" != 1 ]] && systemctl enable  redis-server
}

configure()
{
  ping -W 2 -w 1 -q github.com &>/dev/null || { echo "No internet connectivity"; return 1; }

  ## RE-CREATE DATABASE TABLE 
  echo "Starting mariaDB"

  # launch mariadb if not already running (for docker build)
  [[ "$DOCKERBUILD" == 1 ]] && { mysqld & }

  # wait for mariadb
  pgrep -x mysqld &>/dev/null || { echo "mariaDB process not found"; return 1; }

  while :; do
    [[ -S /var/run/mysqld/mysqld.sock ]] && break
    sleep 0.5
  done

  echo "Setting up database..."

  # workaround to emulate DROP USER IF EXISTS ..;)
  local DBPASSWD=$( grep password /root/.my.cnf | cut -d= -f2 )
  mysql -u root -p"$DBPASSWD" <<EOF
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

  ## DOWNLOAD AND (OVER)WRITE NEXTCLOUD
  cd /var/www/

  echo "Downloading Nextcloud $VER_..."
  wget -q https://download.nextcloud.com/server/releases/nextcloud-$VER_.tar.bz2 -O nextcloud.tar.bz2 || return 1
  rm -rf nextcloud

  echo "Installing  Nextcloud $VER_..."
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
  OPCACHEDIR=/var/www/nextcloud/data/.opcache
  sed -i "s|^opcache.file_cache=.*|opcache.file_cache=$OPCACHEDIR|" /etc/php/7.0/mods-available/opcache.ini 
  mkdir -p $OPCACHEDIR
  chown -R www-data:www-data $OPCACHEDIR

## SET APACHE VHOST
  cat > /etc/apache2/sites-available/nextcloud.conf <<'EOF'
<IfModule mod_ssl.c>
  <VirtualHost _default_:443>
    DocumentRoot /var/www/nextcloud
    CustomLog /var/www/nextcloud/data/access.log combined
    ErrorLog /var/www/nextcloud/data/error.log
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
  echo "Setting up Apache..."

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

  echo "Setting up system..."

  ## SET LIMITS
  sed -i "s/post_max_size=.*/post_max_size=$MAXFILESIZE_/"             /var/www/nextcloud/.user.ini 
  sed -i "s/upload_max_filesize=.*/upload_max_filesize=$MAXFILESIZE_/" /var/www/nextcloud/.user.ini 
  sed -i "s/memory_limit=.*/memory_limit=$MEMORYLIMIT_/"               /var/www/nextcloud/.user.ini 

  # slow transfers will be killed after this time
  cat >> /var/www/nextcloud/.user.ini <<< "max_execution_time=$MAXTRANSFERTIME_"
  cat >> /var/www/nextcloud/.user.ini <<< "max_input_time=$MAXTRANSFERTIME_"

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

