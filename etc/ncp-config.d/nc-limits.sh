#!/bin/bash

# System limit configurator for NextCloudPi
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at https://ownyourbits.com/2017/03/13/nextcloudpi-gets-nextcloudpi-config/
#

MAXFILESIZE_=10G
MEMORYLIMIT_=0
PHPTHREADS_=0
REDISMEM_=0

DESCRIPTION="Configure system limits for NextCloudPi"
INFO="Examples: 200M or 2G. Write 0 for autoconfig"

configure()
{
  # Set auto memory limit to 75% of the total memory
  local TOTAL_MEM="$( free -b | sed -n 2p | awk '{ print $2 }' )"
  AUTOMEM=$(( TOTAL_MEM * 75 / 100 ))

  # MAX FILESIZE
  local CONF=/var/www/nextcloud/.user.ini
  local CURRENT_FILE_SIZE="$( grep "^upload_max_filesize" "$CONF" | sed 's|.*=||' )"
  [[ "$MAXFILESIZE_" == "0" ]] && MAXFILESIZE_=10G

  # MAX PHP MEMORY
  local CONF=/var/www/nextcloud/.user.ini
  local CURRENT_PHP_MEM="$( grep "^memory_limit" "$CONF" | sed 's|.*=||' )"
  [[ "$MEMORYLIMIT_" == "0" ]] && MEMORYLIMIT_=$AUTOMEM && echo "Using ${AUTOMEM}B for PHP"
  sed -i "s/post_max_size=.*/post_max_size=$MAXFILESIZE_/"             "$CONF"
  sed -i "s/upload_max_filesize=.*/upload_max_filesize=$MAXFILESIZE_/" "$CONF"
  sed -i "s/memory_limit=.*/memory_limit=$MEMORYLIMIT_/"               "$CONF"

  # MAX PHP THREADS
  local CONF=/etc/php/7.0/fpm/pool.d/www.conf
  local CURRENT_THREADS=$( grep "^pm.max_children" "$CONF" | awk '{ print $3 }' )
  [[ "$PHPTHREADS_" == "0" ]] && PHPTHREADS_=$( nproc ) && echo "Using $PHPTHREADS_ PHP threads"
  sed -i "s|pm.max_children =.*|pm.max_children = $PHPTHREADS_|"           "$CONF"
  sed -i "s|pm.max_spare_servers =.*|pm.max_spare_servers = $PHPTHREADS_|" "$CONF"
  sed -i "s|pm.start_servers =.*|pm.start_servers = $PHPTHREADS_|"         "$CONF"

  # RESTART PHP
  [[ "$PHPTHREADS_"  != "$CURRENT_THREADS"   ]] || \
  [[ "$MEMORYLIMIT"  != "$CURRENT_PHP_MEM"   ]] || \
  [[ "$MAXFILESIZE_" != "$CURRENT_FILE_SIZE" ]] && {
    bash -c " sleep 3
              service php7.0-fpm stop
              service mysql      stop
              sleep 0.5
              service php7.0-fpm start
              service mysql      start
              " &>/dev/null &
  }

  # redis max memory
  local CONF=/etc/redis/redis.conf
  local CURRENT_REDIS_MEM=$( grep "^maxmemory" "$CONF" | awk '{ print $2 }' )
  [[ "$REDISMEM_" == "0" ]] && REDISMEM_=$AUTOMEM && echo "Using ${AUTOMEM}B for Redis"
  [[ "$REDISMEM_" != "$CURRENT_REDIS_MEM" ]] && {
    sed -i "s|maxmemory .*|maxmemory $REDISMEM_|" "$CONF"
    service redis restart
  }
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
