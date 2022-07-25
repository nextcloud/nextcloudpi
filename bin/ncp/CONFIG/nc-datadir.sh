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
  apt_install btrfs-progs
}

configure()
{
  set -eu -o pipefail
  shopt -s dotglob # includes dot files

  ## CHECKS
  local SRCDIR BASEDIR ENCDIR
  SRCDIR=$( cd /var/www/nextcloud; ncc config:system:get datadirectory ) || {
    echo -e "Error reading data directory. Is NextCloud running and configured?";
    return 1;
  }
  [ -d "${SRCDIR?}" ] || { echo -e "data directory $SRCDIR not found"; return 1; }

  [[ "$SRCDIR" == "${DATADIR?}"      ]] && { echo -e "INFO: data already there"; return 0; }
  [[ "$SRCDIR" == "${DATADIR}"/data ]] && { echo -e "INFO: data already there"; return 0; }

  BASEDIR="${DATADIR}"
  # If the user chooses the root of the mountpoint, force a folder
  mountpoint -q "${BASEDIR?}" && {
    BASEDIR="${BASEDIR}"/ncdata
  }

  mkdir -p "${BASEDIR}"
  BASEDIR="$(cd "${BASEDIR}" && pwd -P)" # resolve symlinks and use the real path
  DATADIR="${BASEDIR}"/data
  ENCDIR="${BASEDIR}"/ncdata_enc

  # checks
  grep -q -e ext -e btrfs <( stat -fc%T "${BASEDIR}" ) || {
    echo -e "Only ext/btrfs filesystems can hold the data directory"
    return 1
  }

  sudo -u www-data test -x "${BASEDIR}" || {
    echo -e "ERROR: the user www-data does not have access permissions over ${BASEDIR}"
    return 1
  }

  # backup possibly existing datadir
  [ -d "${BASEDIR}" ] && {
    rmdir "${BASEDIR}" &>/dev/null || {
      local BKP="${BASEDIR}-$(date "+%m-%d-%y.%s")"
      echo "INFO: ${BASEDIR} is not empty. Creating backup ${BKP?}"
      mv "${BASEDIR}" "${BKP}"
    }
    mkdir -p "${BASEDIR}"
  }

  ## COPY
  cd /var/www/nextcloud
  save_maintenance_mode

  echo "moving data directory from ${SRCDIR} to ${BASEDIR}..."

  # use subvolumes, if BTRFS
  [[ "$(stat -fc%T "${BASEDIR}")" == "btrfs" ]] && {
    echo "BTRFS filesystem detected"
    rmdir "${BASEDIR}"
    btrfs subvolume create "${BASEDIR}"
  }

  # use encryption, if selected
  if is_active_app nc-encrypt; then
    # if we have encryption AND BTRFS, then store ncdata_enc in the subvolume
    mv "$(dirname "${SRCDIR}")"/ncdata_enc "${ENCDIR?}"
    mkdir "${DATADIR}"                        && mount --bind "${SRCDIR}" "${DATADIR}"
    mkdir "$(dirname "${SRCDIR}")"/ncdata_enc && mount --bind "${ENCDIR}" "$(dirname "${SRCDIR}")"/ncdata_enc
  else
    mv "${SRCDIR}" "${DATADIR}"
  fi
  chown www-data: "${DATADIR}"

  # datadir
  sed -i "s|'datadirectory' =>.*|'datadirectory' => '${DATADIR}',|" "${NCDIR?}"/config/config.php
  ncc config:system:set logfile --value="${DATADIR}/nextcloud.log"
  set_ncpcfg datadir "${DATADIR}"

  # tmp upload dir
  mkdir -p "${DATADIR}/tmp"
  chown www-data:www-data "${DATADIR}/tmp"
  ncc config:system:set tempdirectory --value "$DATADIR/tmp"
  sed -i "s|^;\?upload_tmp_dir =.*$|uploadtmp_dir = ${DATADIR}/tmp|"  /etc/php/"${PHPVER?}"/cli/php.ini
  sed -i "s|^;\?upload_tmp_dir =.*$|upload_tmp_dir = ${DATADIR}/tmp|" /etc/php/"${PHPVER}"/fpm/php.ini
  sed -i "s|^;\?sys_temp_dir =.*$|sys_temp_dir = ${DATADIR}/tmp|"     /etc/php/"${PHPVER}"/fpm/php.ini

  # opcache dir
  sed -i "s|^opcache.file_cache=.*|opcache.file_cache=${DATADIR}/.opcache|" /etc/php/"${PHPVER}"/mods-available/opcache.ini

  # update fail2ban logpath
  [[ -f /etc/fail2ban/jail.local ]] && \
  sed -i "s|logpath  =.*nextcloud.log|logpath  = ${DATADIR}/nextcloud.log|" /etc/fail2ban/jail.local

  restore_maintenance_mode

  (
    . "${BINDIR?}/SYSTEM/metrics.sh"
    reload_metrics_config
  )
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

