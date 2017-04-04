#!/bin/bash

# Nextcloud installation on Raspbian 
# Tested with 2017-03-02-raspbian-jessie-lite.img
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh no-ip.sh <IP> (<img>)
#
# See installer.sh instructions for details
#
# Notes:
#   Upon each necessary restart, the system will cut the SSH session, therefore
#   it is required to save the state of the installation. See variable $STATE_FILE
#   It will be necessary to invoke this a number of times for a complete installation
#
# More at https://ownyourbits.com/2017/02/13/nextcloud-ready-raspberry-pi-image/
#

VER=11.0.2
ADMINUSER_=admin
DBADMIN_=ncadmin
DBPASSWD_=ownyourbits
MAXFILESIZE_=768M
MAXTRANSFERTIME_=3600
OPCACHEDIR=/var/www/nextcloud/data/.opcache
CONFDIR=/usr/local/etc/nextcloudpi-config.d/
STATE_FILE=/home/pi/.installation_state
APTINSTALL="apt-get install -y --no-install-recommends"


install()
{
test -f $STATE_FILE && STATE=$( cat $STATE_FILE 2>/dev/null )
if [ "$STATE" == "" ]; then

  # RESIZE IMAGE
  ##########################################

  SECTOR=$( fdisk -l /dev/sda | grep Linux | awk '{ print $2 }' )
  echo -e "d\n2\nn\np\n2\n$SECTOR\n\nw\n" | fdisk /dev/sda || true

  echo 0 > $STATE_FILE 
  nohup reboot &>/dev/null &
elif [ "$STATE" == "0" ]; then

  # UPDATE EVERYTHING
  ##########################################
  resize2fs /dev/sda2

  apt-get update
  apt-get upgrade 
  apt-get dist-upgrade 
  $APTINSTALL rpi-update 
  echo -e "y\n" | rpi-update

  echo 1 > $STATE_FILE 
  nohup reboot &>/dev/null &
elif [ "$STATE" == "1" ]; then

  # GET STRETCH SOURCES FOR HTTP2 AND PHP7
  ##########################################

  echo "deb http://mirrordirector.raspbian.org/raspbian/ stretch main contrib non-free rpi" >> /etc/apt/sources.list
  cat > /etc/apt/preferences <<EOF
Package: *
Pin: release n=jessie
Pin-Priority: 600
EOF
  apt-get update

  # INSTALL FROM STRETCH
  ##########################################

  $APTINSTALL -t stretch apache2
  $APTINSTALL -t stretch php7.0 php7.0-curl php7.0-gd php7.0-fpm php7.0-cli php7.0-opcache php7.0-mbstring php7.0-xml php7.0-zip 
  $APTINSTALL php7.0-APC 
  $APTINSTALL libxml2-dev php-zip php-dom php-xmlwriter php-xmlreader php-gd php-curl php-mbstring 

  debconf-set-selections <<< "mariadb-server-5.5 mysql-server/root_password password $DBPASSWD_"
  debconf-set-selections <<< "mariadb-server-5.5 mysql-server/root_password_again password $DBPASSWD_"
  $APTINSTALL mariadb-server php7.0-mysql 

  # CONFIGURE APACHE AND PHP7
  ##########################################

  cat >/etc/apache2/conf-available/http2.conf <<EOF
Protocols h2 h2c http/1.1

H2Push          on
H2PushPriority  *                       after
H2PushPriority  text/css                before
H2PushPriority  image/jpeg              after   32
H2PushPriority  image/png               after   32
H2PushPriority  application/javascript  interleaved

SSLProtocol all -SSLv2 -SSLv3
SSLHonorCipherOrder on
SSLCipherSuite 'EECDH+ECDSA+AESGCM EECDH+aRSA+AESGCM EECDH+ECDSA+SHA384 EECDH+ECDSA+SHA256 EECDH+aRSA+SHA384 EECDH+aRSA+SHA256 EECDH+aRSA+RC4 EECDH EDH+aRSA !RC4 !aNULL !eNULL !LOW !3DES !MD5 !EXP !PSK !SRP !DSS'
EOF

  cat >> /etc/apache2/apache2.conf <<EOF
<IfModule mod_headers.c>
  Header always set Strict-Transport-Security "max-age=15768000; includeSubDomains; preload"
</IfModule>
EOF

  cat > /etc/php/7.0/mods-available/apcu.ini <<EOF
extension=apcu.so
apc.enable_cli=0
apc.shm_size=256M
apc.ttl=7200
apc.gc_ttl=3600
apc.entries_hint=4096
apc.slam_defense=1
apc.serializer=igbinary
EOF

  cat > /etc/php/7.0/mods-available/opcache.ini <<EOF
zend_extension=opcache.so
opcache.file_cache=$OPCACHEDIR;
opcache.fast_shutdown=1
EOF

  a2enmod http2
  a2enconf http2 
  a2enmod proxy_fcgi setenvif
  a2enconf php7.0-fpm
  a2enmod rewrite
  a2enmod headers
  a2enmod env
  a2enmod dir
  a2enmod mime
  a2enmod ssl

  echo 2 > $STATE_FILE 
  nohup reboot &>/dev/null &

elif [ "$STATE" == "2" ]; then
  # INSTALL NEXTCLOUD
  ##########################################

  cd /var/www/
  wget https://download.nextcloud.com/server/releases/nextcloud-$VER.tar.bz2 -O nextcloud.tar.bz2
  tar -xvf nextcloud.tar.bz2
  rm nextcloud.tar.bz2

  ocpath='/var/www/nextcloud'
  htuser='www-data'
  htgroup='www-data'
  rootuser='root'

  printf "Creating possible missing Directories\n"
  mkdir -p $ocpath/data
  mkdir -p $ocpath/updater
  mkdir -p $OPCACHEDIR

  printf "chmod Files and Directories\n"
  find ${ocpath}/ -type f -print0 | xargs -0 chmod 0640
  find ${ocpath}/ -type d -print0 | xargs -0 chmod 0750

  printf "chown Directories\n"
  # recommended defaults do not play well with updater app
  # re-check this with every new version
  #chown -R ${rootuser}:${htgroup} ${ocpath}/
  chown -R ${htuser}:${htgroup} ${ocpath}/
  chown -R ${htuser}:${htgroup} ${ocpath}/apps/
  chown -R ${htuser}:${htgroup} ${ocpath}/config/
  chown -R ${htuser}:${htgroup} ${ocpath}/data/
  chown -R ${htuser}:${htgroup} ${ocpath}/themes/
  chown -R ${htuser}:${htgroup} ${ocpath}/updater/
  chown -R ${htuser}:${htgroup} $OPCACHEDIR

  chmod +x ${ocpath}/occ

  printf "chmod/chown .htaccess\n"
  if [ -f ${ocpath}/.htaccess ]; then
    # breaks updater, see above
    #chmod 0644 ${ocpath}/.htaccess
    chmod 0664 ${ocpath}/.htaccess
    chown ${rootuser}:${htgroup} ${ocpath}/.htaccess
  fi
  if [ -f ${ocpath}/data/.htaccess ]; then
    chmod 0644 ${ocpath}/data/.htaccess
    chown ${rootuser}:${htgroup} ${ocpath}/data/.htaccess
  fi

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
  </Directory>
</IfModule>
EOF
  a2ensite nextcloud

  mysql -u root -p$DBPASSWD_ <<EOF
CREATE DATABASE nextcloud;
CREATE USER '$DBADMIN_'@'localhost' IDENTIFIED BY '$DBPASSWD_';
GRANT ALL PRIVILEGES ON nextcloud.* TO $DBADMIN_@localhost;
EXIT
EOF

  # NEXTCLOUDPI-CONFIG
  ##########################################

  $APTINSTALL dialog
  mkdir -p $CONFDIR
  sed -i '/Change User Password/i"0 NextCloudPi Configuration" "Configuration of NextCloudPi" \\\\'  /usr/bin/raspi-config
  sed -i '/1\\\\ \*) do_change_pass ;;/i0\\\\ *) nextcloudpi-config ;;'                              /usr/bin/raspi-config

  # NEXTCLOUDPI MOTD
  ##########################################
  mkdir /etc/update-motd.d
  rm /etc/motd
  ln -s /var/run/motd /etc/motd

  cat > /etc/update-motd.d/10logo <<EOF
#!/bin/sh
echo
cat /usr/local/etc/ncp-ascii.txt
EOF

  cat > /etc/update-motd.d/20updates <<'EOF'
#!/bin/bash
/usr/local/bin/ncp-check-updates
EOF
  chmod a+x /etc/update-motd.d/*

  # NEXTCLOUDPI UPDATES
  ##########################################
  $APTINSTALL git

  cat > /etc/cron.daily/ncp-check-version <<EOF
#!/bin/sh
/usr/local/bin/ncp-check-version
EOF
  chmod a+x /etc/cron.daily/ncp-check-version


  cat > /usr/local/bin/ncp-update <<'EOF'
#!/bin/bash
{
  ping  -W 2 -w 1 -q github.com &>/dev/null || { echo "No internet connectivity"; exit 1; }
  echo -e "Downloading updates"
  rm -rf /tmp/ncp-update-tmp
  git clone -q --depth 1 https://github.com/nachoparker/nextcloud-raspbian-generator.git /tmp/ncp-update-tmp || exit 1
  cd /tmp/ncp-update-tmp

  echo -e "Performing updates"
  ./update.sh

  VER=$( git describe --always --tags )
  echo $VER > /usr/local/etc/ncp-version
  echo $VER > /var/run/.ncp-latest-version

  cd /
  rm -rf /tmp/ncp-update-tmp

  echo -e "NextCloudPi updated to version \e[1m$VER\e[0m"
  exit
}
EOF
  chmod a+x /usr/local/bin/ncp-update

  # update to latest version from github as part of the build process
  /usr/local/bin/ncp-update
fi
}

configure()
{ 
  [ "$STATE" != "2" ] && return
  cd /var/www/nextcloud/

  sudo -u www-data php occ maintenance:install --database \
  "mysql" --database-name "nextcloud"  --database-user "$DBADMIN_" --database-pass \
  "$DBPASSWD_" --admin-user "$ADMINUSER_" --admin-pass "$DBPASSWD_" 

  sudo -u www-data php occ background:cron

  sed -i '$s|^.*$|  '\''memcache.local'\'' => '\''\\\\OC\\\\Memcache\\\\APCu'\'',\\n);|' /var/www/nextcloud/config/config.php

  sed -i "s/post_max_size=.*/post_max_size=$MAXFILESIZE_/"             /var/www/nextcloud/.user.ini 
  sed -i "s/upload_max_filesize=.*/upload_max_filesize=$MAXFILESIZE_/" /var/www/nextcloud/.user.ini 
  sed -i "s/memory_limit=.*/memory_limit=$MAXFILESIZE_/"               /var/www/nextcloud/.user.ini 

  # slow transfers will be killed after this time
  cat >> /var/www/nextcloud/.user.ini <<< "max_execution_time=$MAXTRANSFERTIME_"

  echo "*/15  *  *  *  * php -f /var/www/nextcloud/cron.php" > /tmp/crontab_http
  crontab -u www-data /tmp/crontab_http
  rm /tmp/crontab_http

  cat > /usr/local/bin/nextcloud-domain.sh <<'EOF'
#!/bin/bash
IFACE=$( ip r | grep "default via" | awk '{ print $5 }' )
IP=$( ip a | grep "global $IFACE" | grep -oP '\d{1,3}(.\d{1,3}){3}' | head -1 )
cd /var/www/nextcloud
sudo -u www-data php occ config:system:set trusted_domains 1 --value=$IP
EOF

  mkdir -p /usr/lib/systemd/system
  cat > /usr/lib/systemd/system/nextcloud-domain.service <<'EOF'
[Unit]
Description=Register Current IP as Nextcloud trusted domain
Requires=network.target
After=mysql.service

[Service]
ExecStart=/bin/bash /usr/local/bin/nextcloud-domain.sh

[Install]
WantedBy=multi-user.target
EOF
  systemctl enable nextcloud-domain
}

cleanup()   
{ 
  [ "$STATE" != "2" ] && return
  apt-get autoremove
  apt-get clean
  rm /var/lib/apt/lists/* -r
  rm -f /home/pi/.bash_history

  systemctl disable ssh
  rm $STATE_FILE 
  nohup halt &>/dev/null &
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

