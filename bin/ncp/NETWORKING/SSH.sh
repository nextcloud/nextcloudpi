#!/bin/bash

# Activate/deactivate SSH
#
#
# Copyleft 2017 by Courtney Hicks and Ignacio Nunez Hernanz
# GPL licensed (see end of file) * Use at your own risk!
#


install() { :; }

is_active()
{
  systemctl -q is-enabled ssh &>/dev/null
}

configure()
{
  [[ $ACTIVE != "yes" ]]  && {
    systemctl stop    ssh
    systemctl disable ssh
    echo "SSH disabled"
    return 0
  }

  # Check for bad ideas
  [[ "$USER" == "pi" ]] && [[ "$PASS" == "raspberry" ]] && {
    echo "Refusing to use the default Raspbian user and password. It's insecure"
    return 1
  }
  [[ "$USER" == "root" ]] && {
    echo "Refusing to use the root user for SSH. It's insecure"
    return 1
  }

  # Change credentials
  id "$USER" &>/dev/null || { echo "$USER doesn't exist"; return 1; }
  echo -e "$PASS\n$CONFIRM" | passwd "$USER" || return 1

  # Reenable pi user
  chsh -s /bin/bash "$USER"

  # Check for insecure default pi password ( taken from old jessie method )
  # TODO Due to Debian bug #1003151 with mkpasswd this feature is not working properly at the moment - https://www.mail-archive.com/debian-bugs-dist@lists.debian.org/msg1837456.html
  #local SHADOW SALT HASH
  #SHADOW="$( grep -E '^pi:' /etc/shadow )"
  #test -n "${SHADOW}" && {
    #SALT=$(awk -F[:$] '{print $5}' <<<"${SHADOW}")

    #[[ "${SALT}" != "" ]] && {
      #HASH=$(mkpasswd -myescrypt raspberry "${SALT}")
      #grep -q "${HASH}" <<< "${SHADOW}" && {
        #systemctl stop    ssh
        #systemctl disable ssh
        #echo "The user pi is using the default password. Refusing to activate SSH"
        #echo "SSH disabled"
        #return 1
      #}
    #}
  #}

  # Check for insecure default root password ( taken from old jessie method )
  #SHADOW="$( grep -E '^root:' /etc/shadow )"
  #test -n "${SHADOW}" && {
    #SALT=$(awk -F[:$] '{print $5}' <<<"${SHADOW}")

    #[[ "${SALT}" != "" ]] && {
      #HASH=$(mkpasswd -myescrypt 1234 "${SALT}")
      #grep -q "${HASH}" <<< "${SHADOW}" && {
        #systemctl stop    ssh
        #systemctl disable ssh
        #echo "The user root is using the default password. Refusing to activate SSH"
        #echo "SSH disabled"
        #return 1
      #}
    #}
  #}

  # Enable
  chage -d 0 "$USER"
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
