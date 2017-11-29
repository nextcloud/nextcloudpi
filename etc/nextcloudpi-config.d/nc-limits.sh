#!/bin/bash

# System limit configurator for NextCloudPi
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh nc-limits.sh <IP> (<img>)
#
# See installer.sh instructions for details
#
# More at https://ownyourbits.com/2017/03/13/nextcloudpi-gets-nextcloudpi-config/
#

MAXFILESIZE_=2G
MEMORYLIMIT_=768M
PHPTHREADS_=0
REDISMEM_=3gb

DESCRIPTION="Configure system limits for NextCloudPi"
INFO="Set PHP threads to 0 in order to use all cores"

configure()
{
  sed -i "s/post_max_size=.*/post_max_size=$MAXFILESIZE_/"             /var/www/nextcloud/.user.ini
  sed -i "s/upload_max_filesize=.*/upload_max_filesize=$MAXFILESIZE_/" /var/www/nextcloud/.user.ini
  sed -i "s/memory_limit=.*/memory_limit=$MEMORYLIMIT_/"               /var/www/nextcloud/.user.ini

  # adjust max PHP processes so Apps don't overload the board (#146)
  [[ $PHPTHREADS_ -eq 0 ]] && PHPTHREADS_=$( nproc ) && echo "Using $PHPTHREADS_ PHP threads"
  sed -i "s|pm.max_children =.*|pm.max_children = $PHPTHREADS_|"           /etc/php/7.0/fpm/pool.d/www.conf
  sed -i "s|pm.max_spare_servers =.*|pm.max_spare_servers = $PHPTHREADS_|" /etc/php/7.0/fpm/pool.d/www.conf
  sed -i "s|pm.start_servers =.*|pm.start_servers = $PHPTHREADS_|"         /etc/php/7.0/fpm/pool.d/www.conf

  # need to restart php
  bash -c " sleep 3
            systemctl stop php7.0-fpm
            systemctl stop mysqld
            sleep 0.5
            systemctl start php7.0-fpm
            systemctl start mysqld
            " &>/dev/null &

  # redis max memory
  sed -i "s|maxmemory .*|maxmemory $REDISMEM_|" /etc/redis/redis.conf
  systemctl restart redis
}

install() { :; }

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

