#!/bin/bash

# System limits configuration for NextCloudPi
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at https://ownyourbits.com/2017/03/13/nextcloudpi-gets-nextcloudpi-config/
#

PHPVER=7.2


configure()
{
  # Set auto memory limit to 75% of the total memory
  local TOTAL_MEM="$( free -b | sed -n 2p | awk '{ print $2 }' )"
  AUTOMEM=$(( TOTAL_MEM * 75 / 100 ))

  # MAX FILESIZE
  local CONF=/var/www/nextcloud/.user.ini
  local CURRENT_FILE_SIZE="$( grep "^upload_max_filesize" "$CONF" | sed 's|.*=||' )"
  [[ "$MAXFILESIZE" == "0" ]] && MAXFILESIZE=10G

  # MAX PHP MEMORY
  local CONF=/var/www/nextcloud/.user.ini
  local CURRENT_PHP_MEM="$( grep "^memory_limit" "$CONF" | sed 's|.*=||' )"
  [[ "$MEMORYLIMIT" == "0" ]] && MEMORYLIMIT=$AUTOMEM && echo "Using ${AUTOMEM}B for PHP"
  sed -i "s/^post_max_size=.*/post_max_size=$MAXFILESIZE/"             "$CONF" 
  sed -i "s/^upload_max_filesize=.*/upload_max_filesize=$MAXFILESIZE/" "$CONF" 
  sed -i "s/^memory_limit=.*/memory_limit=$MEMORYLIMIT/"               "$CONF" 

  # MAX PHP THREADS
  local CONF=/etc/php/${PHPVER}/fpm/pool.d/www.conf
  local CURRENT_THREADS=$( grep "^pm.max_children" "$CONF" | awk '{ print $3 }' )
  [[ "$PHPTHREADS" == "0" ]] && PHPTHREADS=$( nproc ) && echo "Using $PHPTHREADS PHP threads"
  sed -i "s|^pm.max_children =.*|pm.max_children = $PHPTHREADS|"           "$CONF"
  sed -i "s|^pm.max_spare_servers =.*|pm.max_spare_servers = $PHPTHREADS|" "$CONF"
  sed -i "s|^pm.start_servers =.*|pm.start_servers = $PHPTHREADS|"         "$CONF"

  # RESTART PHP
  [[ "$PHPTHREADS"  != "$CURRENT_THREADS"   ]] || \
  [[ "$MEMORYLIMIT" != "$CURRENT_PHP_MEM"   ]] || \
  [[ "$MAXFILESIZE" != "$CURRENT_FILE_SIZE" ]] && \
    bash -c "sleep 3; service php${PHPVER}-fpm restart" &>/dev/null &

  # redis max memory
  local CONF=/etc/redis/redis.conf
  local CURRENT_REDIS_MEM=$( grep "^maxmemory" "$CONF" | awk '{ print $2 }' )
  [[ "$REDISMEM" != "$CURRENT_REDIS_MEM" ]] && {
    sed -i "s|^maxmemory .*|maxmemory $REDISMEM|" "$CONF"
    service redis-server restart
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

