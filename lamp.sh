#!/bin/bash

# Nextcloud LAMP base installation on Raspbian 
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh lamp.sh <IP> (<img>)
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

APTINSTALL="apt-get install -y --no-install-recommends"
export DEBIAN_FRONTEND=noninteractive

install()
{
    apt-get update

    # INSTALL 
    ##########################################

    $APTINSTALL apt-utils 
    $APTINSTALL cron
    $APTINSTALL apache2
    $APTINSTALL php7.0 php7.0-curl php7.0-gd php7.0-fpm php7.0-cli php7.0-opcache php7.0-mbstring php7.0-xml php7.0-zip php7.0-APC php7.0-fileinfo php7.0-mcrypt
    mkdir -p /run/php

    # Randomize mariaDB password
    # Suggested by @enoch85 and taken from the nextcloud vm ( https://github.com/nextcloud/vm/blob/master/lib.sh#L46 )
    DBPASSWD=$(tr -dc "a-zA-Z0-9@#*=" < /dev/urandom | fold -w "$(shuf -i 30-35 -n 1)" | head -n 1)
    echo -e "[client]\npassword=$DBPASSWD" > /root/.my.cnf
    chmod 600 /root/.my.cnf

    debconf-set-selections <<< "mariadb-server-5.5 mysql-server/root_password password $DBPASSWD"
    debconf-set-selections <<< "mariadb-server-5.5 mysql-server/root_password_again password $DBPASSWD"
    $APTINSTALL mariadb-server php7.0-mysql 
    mkdir -p /run/mysqld
    chown mysql /run/mysqld

    # CONFIGURE APACHE 
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

    # CONFIGURE PHP7
    ##########################################

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
opcache.fast_shutdown=1
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=10000
opcache.memory_consumption=128
opcache.save_comments=1
opcache.revalidate_freq=1
opcache.file_cache=/tmp;
EOF

    a2enmod http2
    a2enconf http2 
    a2enmod proxy_fcgi setenvif
    a2enconf php7.0-fpm
    a2enmod rewrite
    a2enmod headers
    a2enmod dir
    a2enmod mime
    a2enmod ssl
    
    a2dismod -f status reqtimeout env autoindex access_compat auth_basic authn_file authn_core alias access_compat
    echo "ServerName localhost" >> /etc/apache2/apache2.conf


    # CONFIGURE LAMP FOR NEXTCLOUD
    ##########################################

    $APTINSTALL ssl-cert # self signed snakeoil certs

    # configure MariaDB ( UTF8 4 byte support )
    sed -i '/\[mysqld\]/ainnodb_large_prefix=on'       /etc/mysql/mariadb.conf.d/50-server.cnf 
    sed -i '/\[mysqld\]/ainnodb_file_per_table=1'      /etc/mysql/mariadb.conf.d/50-server.cnf 
    sed -i '/\[mysqld\]/ainnodb_file_format=barracuda' /etc/mysql/mariadb.conf.d/50-server.cnf

  # launch mariadb if not already running (for docker build)
  [[ "$DOCKERBUILD" == 1 ]] && { mysqld & }

  # wait for mariadb
  while :; do
    [[ -S /var/run/mysqld/mysqld.sock ]] && break
    sleep 0.5
  done
    mysql_secure_installation <<EOF
$DBPASSWD
n
y
y
y
y
EOF

  # adjust max PHP processes so Apps don't overload the board (#146)
  sed -i 's|pm.max_children =.*|pm.max_children = 3|' /etc/php/7.0/fpm/pool.d/www.conf
}

configure() { :; }

cleanup()   
{ 
  apt-get autoremove -y
  apt-get clean
  rm /var/lib/apt/lists/* -r
  rm -f /home/pi/.bash_history

  systemctl disable ssh
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

