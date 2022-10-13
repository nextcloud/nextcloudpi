#!/bin/bash

# Data at rest encryption for NextcloudPi
#
# Copyleft 2021 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at: nextcloudpi.com
#

is_active()
{
  mount | grep ncdata_enc | grep -q gocryptfs
}

install()
{
  apt_install gocryptfs
}

configure()
{
(
  set -e -o pipefail
  local datadir parentdir encdir tmpdir
  datadir="$(get_ncpcfg datadir)"
  [[ "${datadir?}" == "null" ]] && datadir=/var/www/nextcloud/data
  parentdir="$(dirname "${datadir}")"
  encdir="${parentdir?}/ncdata_enc"
  tmpdir="$(mktemp -u -p "${parentdir}" -t nc-data-crypt.XXXXXX))"

  [[ "${ACTIVE?}" != "yes" ]] && {
    if ! is_active; then
      echo "Data not currently encrypted"
      return 0
    fi
    save_maintenance_mode
    trap restore_maintenance_mode EXIT
    echo "Decrypting data..."
    mkdir "${tmpdir?}"
    chown www-data: "${tmpdir}"
    pkill tail # prevents from umounting in docker
    mv "${datadir?}"/* "${datadir}"/.[!.]* "${tmpdir}"
    fusermount -u "${datadir}"
    rmdir "${datadir}"
    mv "${tmpdir}" "${datadir}"
    rm "${encdir?}"/gocryptfs.*
    rmdir "${encdir}"
    echo "Data no longer encrypted"
    return
  }

  if is_active; then
    echo "Encrypted data already in use"
    return
  fi

  # Just mount already encrypted data
  if [[ -f "${encdir?}"/gocryptfs.conf ]]; then
    echo "${PASSWORD?}" | gocryptfs -allow_other -q "${encdir}" "${datadir}" 2>&1 | sed /^Switch/d

    # switch to the regular virtual hosts after we decrypt, so we can access NC and ncp-web
    a2ensite ncp nextcloud
    a2dissite ncp-activation
    apache2ctl -k graceful

    echo "Encrypted data now accessible"
    return
  fi
  mkdir -p "${encdir?}"
  echo "${PASSWORD?}" | gocryptfs -init -q "${encdir}"
  save_maintenance_mode
  trap restore_maintenance_mode EXIT

  mv "${datadir?}" "${tmpdir?}"

  mkdir "${datadir}"
  echo "${PASSWORD}" | gocryptfs -allow_other -q "${encdir}" "${datadir}" 2>&1 | sed /^Switch/d

  echo "Encrypting data..."
  mv "${tmpdir}"/* "${tmpdir}"/.[!.]* "${datadir}"
  chown -R www-data: "${datadir}"
  rmdir "${tmpdir}"

  set_ncpcfg datadir "${datadir}"

  echo "Data is now encrypted"
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

