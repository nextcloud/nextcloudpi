#!/bin/bash

# Nextcloud LAMP base installation on Raspbian 
# Tested with 2017-03-02-raspbian-jessie-lite.img
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh nextcloud_lamp.sh <IP> (<img>)
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

DBADMIN_=ncadmin
DBPASSWD_=ownyourbits
OPCACHEDIR=/var/www/nextcloud/data/.opcache
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
    apt-get upgrade -y
    apt-get dist-upgrade -y
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
opcache.enable=1
opcache.enable_cli=1
opcache.file_cache=$OPCACHEDIR;
opcache.fast_shutdown=1
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=10000
opcache.memory_consumption=128
opcache.save_comments=1
opcache.revalidate_freq=1
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

    # CONFIGURE LAMP FOR NEXTCLOUD
    ##########################################

    $APTINSTALL ssl-cert # self signed snakeoil certs

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
  fi
}

configure() { :; }

cleanup()   
{ 
  [ "$STATE" != "1" ] && return
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

