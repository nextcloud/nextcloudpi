#!/bin/bash

# Activate/deactivate SSH
#
#
# Copyleft 2017 by Courtney Hicks
# GPL licensed (see end of file) * Use at your own risk!
#

ACTIVE_=no
USER_=pi
PASS_=raspberry
CONFIRM_=raspberry

DESCRIPTION="Activate or deactivate SSH"
INFOTITLE="SSH notes"
INFO="In order to enable SSH, the password for user pi can NOT remain set to the default raspberry. 
You HAVE to create a NEW password for pi if you want this program to enable SSH, it will fail if you dont!
Note: Use normal AlphaNumeric, the only special characters allowed are .,@-_/"

install() { :; }

is_active()
{
  systemctl status ssh &>/dev/null
}

configure() 
{
  [[ $ACTIVE_ != "yes" ]]  && {
    systemctl disable ssh
    echo "SSH disabled"
    return 0
  }

  # Check for bad ideas
  [[ "$USER_" == "pi" ]] && [[ "$PASS_" == "raspberry" ]] && {
    echo "Refusing to use the default Raspbian user and password. It's insecure"
    return 1
  }

  # Change credentials
  id "$USER_" &>/dev/null || { echo "$USER_ doesn't exist"; return 1; }
  echo -e "$PASS_\n$CONFIRM_" | passwd "$USER_" || return 1

  # Check for insecure default pi password ( taken from old jessie method )
  local SHADOW="$( grep -E '^pi:' /etc/shadow )"
  test -n "${SHADOW}" && {
    local SALT=$(echo "${SHADOW}" | sed -n 's/pi:\$6\$//;s/\$.*//p')
    local HASH=$(mkpasswd -msha-512 raspberry "$SALT")

    grep -q "${HASH}" <<< "${SHADOW}" && {
      systemctl stop    ssh
      systemctl disable ssh
      echo "The user pi is using the default password. Refusing to activate SSH"
      echo "SSH disabled"
      return 1
    }
  }

  # Enable
  chage -d 0 "$USER_"
  systemctl enable ssh
  systemctl start  ssh
  echo "SSH enabled"
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
