#!/bin/bash

# Data dir configuration script for NextCloudPi
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at https://ownyourbits.com/2017/03/13/nextcloudpi-gets-nextcloudpi-config/
#

is_active()
{
  local SRCDIR
  SRCDIR="$( grep datadirectory /var/www/nextcloud/config/config.php | awk '{ print $3 }' | grep -oP "[^']*[^']" | head -1 )" || return 1
  [[ "$SRCDIR" != "/var/www/nextcloud/data" ]]
}

install()
{
  apt_install btrfs-tools
}

configure()
{
  source /usr/local/etc/library.sh # sets PHPVER

  ## CHECKS
  local SRCDIR
  SRCDIR=$( cd /var/www/nextcloud; ncc config:system:get datadirectory ) || {
    echo -e "Error reading data directory. Is NextCloud running and configured?";
    return 1;
  }
  [ -d "$SRCDIR" ] || { echo -e "data directory $SRCDIR not found"; return 1; }

  [[ "$SRCDIR" == "$DATADIR" ]] && { echo -e "INFO: data already there"; return 0; }

  # checks
  local BASEDIR=$( dirname "$DATADIR" )

  [ -d "$BASEDIR" ] || { echo "$BASEDIR does not exist"; return 1; }

  # If the user chooses the root of the mountpoint, force a folder
  mountpoint -q "$DATADIR" && {
    BASEDIR="$DATADIR"
  }

  grep -q -e ext -e btrfs <( stat -fc%T "$BASEDIR" ) || {
    echo -e "Only ext/btrfs filesystems can hold the data directory"
    return 1
  }

  sudo -u www-data test -x "$BASEDIR" || {
    echo -e "ERROR: the user www-data does not have access permissions over $BASEDIR"
    return 1
  }

  # backup possibly existing datadir
  [ -d $DATADIR ] && {
    local BKP="${DATADIR}-$( date "+%m-%d-%y" )"
    echo "INFO: $DATADIR is not empty. Creating backup $BKP"
    mv "$DATADIR" "$BKP"
  }


  ## COPY
  cd /var/www/nextcloud
  save_maintenance_mode

  echo "moving data directory from $SRCDIR to $DATADIR..."

  # resolve symlinks and use the real path
  mkdir "$DATADIR"
  DATADIR=$(cd "$DATADIR" && pwd -P)
  rmdir "$DATADIR"

  # use subvolumes, if BTRFS
  [[ "$( stat -fc%T "$BASEDIR" )" == "btrfs" ]] && {
    echo "BTRFS filesystem detected"
    btrfs subvolume create "$DATADIR" || return  1
  }

  cp --reflink=auto -raT "$SRCDIR" "$DATADIR" || return 1
  chown www-data:www-data "$DATADIR"

  # tmp upload dir
  mkdir -p "$DATADIR/tmp"
  chown www-data:www-data "$DATADIR/tmp"
  ncc config:system:set tempdirectory --value "$DATADIR/tmp"
  sed -i "s|^;\?upload_tmp_dir =.*$|uploadtmp_dir = $DATADIR/tmp|" /etc/php/${PHPVER}/cli/php.ini
  sed -i "s|^;\?upload_tmp_dir =.*$|upload_tmp_dir = $DATADIR/tmp|" /etc/php/${PHPVER}/fpm/php.ini
  sed -i "s|^;\?sys_temp_dir =.*$|sys_temp_dir = $DATADIR/tmp|"     /etc/php/${PHPVER}/fpm/php.ini

  # opcache dir
  sed -i "s|^opcache.file_cache=.*|opcache.file_cache=$DATADIR/.opcache|" /etc/php/${PHPVER}/mods-available/opcache.ini

  # update fail2ban logpath
  [[ -f /etc/fail2ban/jail.local ]] && \
  sed -i "s|logpath  =.*nextcloud.log|logpath  = $DATADIR/nextcloud.log|" /etc/fail2ban/jail.local

  # datadir
  ncc config:system:set datadirectory --value="$DATADIR"
  ncc config:system:set logfile --value="$DATADIR/nextcloud.log"
  set_ncpcfg datadir "${datadir}"
  restore_maintenance_mode
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

