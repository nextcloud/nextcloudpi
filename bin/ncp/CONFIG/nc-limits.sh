#!/bin/bash

# System limits configuration for NextCloudPi
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at https://ownyourbits.com/2017/03/13/nextcloudpi-gets-nextcloudpi-config/
#

get_total_mem() {
  local total_mem="$(free -b | sed -n 2p | awk '{ print $2 }')"
  local MAX_32BIT=4096000000
  if [[ "$ARCH" == 'armv7' ]] && [[ $MAX_32BIT -lt "$total_mem" ]]
  then
    echo "$MAX_32BIT"
  else
    echo "$total_mem"
  fi

}

tmpl_innodb_buffer_pool_size() {
  local TOTAL_MEM="$(get_total_mem)"
  # DATABASE MEMORY (25%)
  local AUTOMEM=$(( TOTAL_MEM * 25 / 100 ))
  # Maximum MySQL Memory Usage = innodb_buffer_pool_size + key_buffer_size + (read_buffer_size + sort_buffer_size) X max_connections
  # leave 16MiB for key_buffer_size and a bit more
  AUTOMEM=$(( AUTOMEM - (16 + 32) * 1024 * 1024 ))
  echo -n "$AUTOMEM"
}

tmpl_php_max_memory() {
  local TOTAL_MEM="$( get_total_mem )"
  local MEMORYLIMIT="$(find_app_param nc-limits MEMORYLIMIT)"
  [[ "$MEMORYLIMIT" == "0" ]] && echo -n "$(( TOTAL_MEM * 75 / 100 ))" || echo -n "$MEMORYLIMIT"
}

tmpl_php_max_filesize() {
  local FILESIZE="$(find_app_param nc-limits MAXFILESIZE)"
  [[ "$FILESIZE" == "0" ]] && echo -n "10G" || echo -n "$FILESIZE"
}

tmpl_php_threads() {
  local TOTAL_MEM="$( get_total_mem )"
  local PHPTHREADS="$(find_app_param nc-limits PHPTHREADS)"
  # By default restricted by memory / 100MB
  [[ $PHPTHREADS -eq 0 ]] && PHPTHREADS=$(( TOTAL_MEM / ( 100 * 1024 * 1024 ) ))
  # Minimum 16
  [[ $PHPTHREADS -lt 16 ]] && PHPTHREADS=16
   echo -n "$PHPTHREADS"
}

configure()
{
  # Set auto memory limit to 75% of the total memory
  local TOTAL_MEM="$( get_total_mem )"
  # special case of 32bit emulation (e.g. 32bit-docker on 64bit hardware)
  file /bin/bash | grep 64-bit > /dev/null || TOTAL_MEM="$(( 1024 * 1024 * 1024 * 4 ))"
  local AUTOMEM=$(( TOTAL_MEM * 75 / 100 ))

  # MAX FILESIZE

  # MAX PHP MEMORY
  local require_fpm_restart=false
  local CONF=/etc/php/${PHPVER}/fpm/conf.d/90-ncp.ini
  local CONF_VALUE="$(cat "$CONF" 2> /dev/null || true)"
  echo "Using $(tmpl_php_max_memory) for PHP max memory"
  install_template "php/90-ncp.ini.sh" "$CONF"
  [[ "$CONF_VALUE" == "$(cat "$CONF")" ]] || require_fpm_restart=true

  # MAX PHP THREADS
  local CONF=/etc/php/${PHPVER}/fpm/pool.d/www.conf
  CONF_VALUE="$(cat "$CONF" 2> /dev/null || true)"
  echo "Using $(tmpl_php_threads) PHP threads"
  install_template "php/pool.d.www.conf.sh" "$CONF"
  [[ "$CONF_VALUE"  == "$(cat "$CONF")"   ]] || require_fpm_restart=true

  local CONF=/etc/mysql/mariadb.conf.d/91-ncp.cnf
  CONF_VALUE="$(cat "$CONF" 2> /dev/null || true)"
  install_template "mysql/91-ncp.cnf.sh" "$CONF"
  [[ "$CONF_VALUE" == "$(cat "$CONF")" ]] || service mariadb restart

  # RESTART PHP
  [[ "$require_fpm_restart" == "true" ]] && {
    bash -c "sleep 3; source /usr/local/etc/library.sh; clear_opcache; service php${PHPVER}-fpm restart" &>/dev/null &
  }

  # redis max memory
  local CONF=/etc/redis/redis.conf
  local CURRENT_REDIS_MEM="$( grep "^maxmemory" "$CONF" | awk '{ print $2 }' )"
  [[ "$REDISMEM" != "$CURRENT_REDIS_MEM" ]] && {
    sed -i "s|^maxmemory .*|maxmemory $REDISMEM|" "$CONF"
#    chown redis:redis "$CONF"
    systemctl restart redis
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

