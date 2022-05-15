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
    $APTINSTALL apt-utils cron curl
    $APTINSTALL apache2

    $APTINSTALL -t $RELEASE php${PHPVER} php${PHPVER}-curl php${PHPVER}-gd php${PHPVER}-fpm php${PHPVER}-cli php${PHPVER}-opcache \
                            php${PHPVER}-mbstring php${PHPVER}-xml php${PHPVER}-zip php${PHPVER}-fileinfo php${PHPVER}-ldap \
                            php${PHPVER}-intl php${PHPVER}-bz2 php${PHPVER}-json

    mkdir -p /run/php

    ## Android container needs to explicitly set this Apache default 
    [ -e /usr/sbin/unchroot ] && sed -i 's/#Mutex file:${APACHE_LOCK_DIR} default/Mutex file:${APACHE_LOCK_DIR} default/g' /etc/apache2/apache2.conf 
    
    # mariaDB password
    local DBPASSWD="default"
    echo -e "[client]\npassword=$DBPASSWD" > /root/.my.cnf
    chmod 600 /root/.my.cnf

    debconf-set-selections <<< "mariadb-server-5.5 mysql-server/root_password password $DBPASSWD"
    debconf-set-selections <<< "mariadb-server-5.5 mysql-server/root_password_again password $DBPASSWD"
    $APTINSTALL mariadb-server php${PHPVER}-mysql
    mkdir -p /run/mysqld
    chown mysql /run/mysqld

    # CONFIGURE APACHE
    ##########################################

  cat > /etc/apache2/conf-available/http2.conf <<EOF
Protocols h2 h2c http/1.1

# HTTP2 configuration
H2Push          on
H2PushPriority  *                       after
H2PushPriority  text/css                before
H2PushPriority  image/jpeg              after   32
H2PushPriority  image/png               after   32
H2PushPriority  application/javascript  interleaved

# SSL/TLS Configuration
SSLProtocol -all +TLSv1.2 +TLSv1.3
SSLHonorCipherOrder on
SSLCipherSuite ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS
SSLCompression          off
SSLSessionTickets       on

# OCSP Stapling
SSLUseStapling          on
SSLStaplingResponderTimeout 5
SSLStaplingReturnResponderErrors off
SSLStaplingCache        shmcb:/var/run/ocsp(128000)
EOF

    # CONFIGURE PHP7
    ##########################################

    cat > /etc/php/${PHPVER}/mods-available/opcache.ini <<EOF
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
    a2enconf php${PHPVER}-fpm
    a2enmod rewrite
    a2enmod headers
    a2enmod dir
    a2enmod mime
    a2enmod ssl

    echo "ServerName localhost" >> /etc/apache2/apache2.conf


    # CONFIGURE LAMP FOR NEXTCLOUD
    ##########################################

    $APTINSTALL ssl-cert # self signed snakeoil certs

    # configure MariaDB (UTF8 4 byte support)
    cat > /etc/mysql/mariadb.conf.d/90-ncp.cnf <<EOF
[mysqld]
datadir = /var/lib/mysql
EOF
    cat > /etc/mysql/mariadb.conf.d/91-ncp.cnf <<EOF
[mysqld]
transaction_isolation = READ-COMMITTED
innodb_large_prefix=true
innodb_file_per_table=1
innodb_file_format=barracuda

[server]
# innodb settings
skip-name-resolve
innodb_buffer_pool_size = 256M
innodb_buffer_pool_instances = 1
innodb_flush_log_at_trx_commit = 2
innodb_log_buffer_size = 32M
innodb_max_dirty_pages_pct = 90
innodb_log_file_size = 32M

# disable query cache
query_cache_type = 0
query_cache_size = 0

# other
tmp_table_size= 64M
max_heap_table_size= 64M
EOF


  # launch mariadb if not already running
  if ! [[ -f /run/mysqld/mysqld.pid ]]; then
    echo "Starting mariaDB"
    mysqld &
  fi

  # wait for mariadb
  while :; do
    [[ -S /run/mysqld/mysqld.sock ]] && break
    sleep 0.5
  done

  cd /tmp
  mysql_secure_installation <<EOF
$DBPASSWD
y
$DBPASSWD
$DBPASSWD
y
y
y
y
EOF
}

configure() { :; }


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

