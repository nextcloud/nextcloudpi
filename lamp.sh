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
    set -x
    # Setup apt repository for php 8
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
    echo "deb https://packages.sury.org/php/ ${RELEASE%-security} main" > /etc/apt/sources.list.d/php.list
    apt-get update
    $APTINSTALL apt-utils cron curl
    ls -l /var/lock || true
    $APTINSTALL apache2
    # Fix missing lock directory
    mkdir -p /run/lock
    apache2ctl -V || true

    # Create systemd users to keep uids persistent between containers
#    id -u systemd-resolve || {
#      addgroup --quiet --system systemd-journal
#      adduser --quiet -u 180 --system --group --no-create-home --home /run/systemd \
#        --gecos "systemd Network Management" systemd-network
#      adduser --quiet -u 181 --system --group --no-create-home --home /run/systemd \
#        --gecos "systemd Resolver" systemd-resolve
#    }
    install_with_shadow_workaround --no-install-recommends systemd
    $APTINSTALL -t $RELEASE php${PHPVER} php${PHPVER}-curl php${PHPVER}-gd php${PHPVER}-fpm php${PHPVER}-cli php${PHPVER}-opcache \
                            php${PHPVER}-mbstring php${PHPVER}-xml php${PHPVER}-zip php${PHPVER}-fileinfo php${PHPVER}-ldap \
                            php${PHPVER}-intl php${PHPVER}-bz2

    mkdir -p /run/php

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

    install_template apache2/http2.conf.sh /etc/apache2/conf-available/http2.conf --defaults

    # CONFIGURE PHP7
    ##########################################

    install_template "php/opcache.ini.sh" "/etc/php/${PHPVER}/mods-available/opcache.ini" --defaults

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

    install_template "mysql/90-ncp.cnf.sh" "/etc/mysql/mariadb.conf.d/90-ncp.cnf" --defaults

    install_template "mysql/91-ncp.cnf.sh" "/etc/mysql/mariadb.conf.d/91-ncp.cnf" --defaults

  # launch mariadb if not already running
  if ! [[ -f /run/mysqld/mysqld.pid ]]; then
    echo "Starting mariaDB"
    sudo -u mysql mysqld &
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

