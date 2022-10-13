#!/bin/bash

# SAMBA server for Raspbian
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at: https://ownyourbits.com
#


install()
{
  apt-get update
  apt-get install --no-install-recommends -y samba
  update-rc.d smbd disable
  update-rc.d nmbd disable

  # the directory needs to be recreated if we are using nc-ramlogs
  grep -q mkdir /etc/init.d/smbd || sed -i "/\<start)/amkdir -p /var/log/samba" /etc/init.d/smbd

  # disable SMB1 and SMB2
  grep -q SMB3 /etc/samba/smb.conf || sed -i '/\[global\]/aprotocol = SMB3' /etc/samba/smb.conf

  # disable the [homes] share by default
  sed -i /\[homes\]/s/homes/homes_disabled_ncp/ /etc/samba/smb.conf

  cat >> /etc/samba/smb.conf <<EOF

# NextcloudPi automatically generated from here. Do not remove this comment
EOF
}

configure()
{
  [[ $ACTIVE != "yes" ]] && {
    service smbd stop
    update-rc.d smbd disable
    update-rc.d nmbd disable
    echo "SMB disabled"
    return
  }

  # CHECKS
  ################################
  local DATADIR
  DATADIR=$( get_nc_config_value datadirectory ) || {
    echo -e "Error reading data directory. Is NextCloud running and configured?";
    return 1;
  }
  [ -d "$DATADIR" ] || { echo -e "data directory $DATADIR not found"   ; return 1; }

  # CONFIG
  ################################

  # remove files from this line to the end
  sed -i '/# NextcloudPi automatically/,/\$/d' /etc/samba/smb.conf

  # restore this line
  cat >> /etc/samba/smb.conf <<EOF
# NextcloudPi automatically generated from here. Do not remove this comment
EOF

  # create a share per Nextcloud user
  local USERS=()
  while read -r path; do
    USERS+=( "$( basename "$(dirname "$path")" )" )
  done < <( ls -d "$DATADIR"/*/files )

  for user in "${USERS[@]}"; do
    # Exclude users not matching group filter (if enabled)
    if [[ -n "$FILTER_BY_GROUP" ]] \
    && [[ -z "$(ncc user:info "$user" --output=json | jq ".groups[] | select( . == \"${FILTER_BY_GROUP}\" )")" ]]
    then
      echo "Omitting user $user (not in group ${FILTER_BY_GROUP})...";
      continue;
    fi

    echo "adding SAMBA share for user $user"
    local DIR="$DATADIR/$user/files"
    [ -d "$DIR" ] || { echo -e "INFO: directory $DIR does not exist."; return 1; }

    cat >> /etc/samba/smb.conf <<EOF

[ncp-$user]
    path = $DIR
    writeable = yes
;	browseable = yes
    valid users = $user
    force user = www-data
    force group = www-data
    create mask = 0770
    directory mask = 0771
    force create mode = 0660
    force directory mode = 0770

EOF

    ## create user with no login if it doesn't exist
    id "$user" &>/dev/null || adduser --disabled-password --force-badname --gecos "" "$user" || return 1
    echo -e "$PWD\n$PWD" | smbpasswd -s -a "${user}"

    usermod -aG www-data "${user}"
    sudo chmod g+w "${DIR}"
  done

  update-rc.d smbd defaults
  update-rc.d smbd enable
  service smbd restart

  update-rc.d nmbd enable
  service nmbd restart

  echo "SMB enabled"
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
