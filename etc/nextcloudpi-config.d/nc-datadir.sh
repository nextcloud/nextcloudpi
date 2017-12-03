#!/bin/bash

# Data dir configuration script for NextCloudPi
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh nc-datadir.sh <IP> (<img>)
#
# See installer.sh instructions for details
#
# More at https://ownyourbits.com/2017/03/13/nextcloudpi-gets-nextcloudpi-config/
#

DATADIR_=/media/USBdrive/ncdata
DESCRIPTION="Change your data dir to a new location, like a USB drive"

INFO="Note that non Unix filesystems such as NTFS are not supported
because they do not provide a compatible user/permissions system"

is_active()
{
  local SRCDIR
  SRCDIR=$( cd /var/www/nextcloud; sudo -u www-data php occ config:system:get datadirectory ) || return 1;
  [[ "$SRCDIR" != "/var/www/nextcloud/data" ]]
}

install() 
{ 
  apt-get update 
  apt-get install -y --no-install-recommends btrfs-tools
}

configure()
{
  ## CHECKS
  local SRCDIR
  SRCDIR=$( cd /var/www/nextcloud; sudo -u www-data php occ config:system:get datadirectory ) || {
    echo -e "Error reading data directory. Is NextCloud running and configured?"; 
    return 1;
  }
  [ -d "$SRCDIR" ] || { echo -e "data directory $SRCDIR not found"; return 1; }

  [[ "$SRCDIR" == "$DATADIR_" ]] && { echo -e "INFO: data already there"; return 0; }

  # check datadir exists
  [ -d $DATADIR_ ] && {
    local BKP="${DATADIR_}-$( date "+%m-%d-%y" )" 
    echo "INFO: $DATADIR_ is not empty. Creating backup $BKP"
    mv "$DATADIR_" "$BKP"
  }

  local BASEDIR=$( dirname "$DATADIR_" )

  [ -d "$BASEDIR" ] || { echo "$BASEDIR does not exist"; return 1; }

  grep -q -e ext -e btrfs <( stat -fc%T "$BASEDIR" ) || { echo -e "Only ext/btrfs filesystems can hold the data directory"; return 1; }

  sudo -u www-data test -x "$BASEDIR" || { echo -e "ERROR: the user www-data does not have access permissions over $BASEDIR"; return 1; }

  [[ $( stat -fc%d / ) == $( stat -fc%d "$BASEDIR" ) ]] && {
    echo "Refusing to move to the SD card. Abort"
    return 1
  }

  ## COPY
  cd /var/www/nextcloud
  sudo -u www-data php occ maintenance:mode --on

  echo "moving data dir from $SRCDIR to $DATADIR_..."

  # use subvolumes, if BTRFS
  [[ "$( stat -fc%T "$BASEDIR" )" == "btrfs" ]] && {
    echo "BTRFS filesystem detected"
    btrfs subvolume create "$DATADIR_" || return 1
  }

  cp -raT "$SRCDIR" "$DATADIR_" || return 1
 
  # tmp upload dir
  mkdir -p "$DATADIR_/tmp" 
  chown www-data:www-data "$DATADIR_/tmp"
  sed -i "s|^;\?upload_tmp_dir =.*$|upload_tmp_dir = $DATADIR_/tmp|" /etc/php/7.0/fpm/php.ini

  # opcache dir
  sed -i "s|^opcache.file_cache=.*|opcache.file_cache=$DATADIR_/.opcache|" /etc/php/7.0/mods-available/opcache.ini

  # update fail2ban logpath
  sed -i "s|logpath  =.*|logpath  = $DATADIR_/nextcloud.log|" /etc/fail2ban/jail.conf

  # datadir
  sudo -u www-data php occ config:system:set datadirectory --value="$DATADIR_"
  sudo -u www-data php occ maintenance:mode --off
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

