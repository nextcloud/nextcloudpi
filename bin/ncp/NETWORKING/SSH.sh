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
  [[ "$ACTIVE" != "yes" ]]  && {
    systemctl stop    ssh
    systemctl disable ssh
    echo "SSH disabled"
    return 0
  }

  # Check for bad ideas
  [[ "${USER,,}" == "pi" ]] && [[ "${PASS,,}" == "raspberry" ]] && {
    echo "Refusing to use the default Raspbian user and password. It's insecure"
    return 1
  }
  [[ "${USER,,}" == "root" ]] && {
    echo "Refusing to use the root user for SSH. It's insecure"
    return 1
  }
  # Disallow the webadmin to be used for SSH
  [[ "${USER,,}" == "ncp" ]] && {
    echo "The webadmin is not allowed to be used, pick another username"
    return 1
  }

  # Change or create credentials
  if id "$USER" &>/dev/null
  then
    echo "$USER exists, setting password"
    echo -e "$PASS\n$CONFIRM" | passwd "$USER" || return 1
  else
    echo "Creating $USER & setting password"
    # The ,, ensures the users home directory is in lowercase letters
    useradd --create-home --home-dir /home/"${USER,,}" --shell /bin/bash "$USER" || return 1
    echo -e "$PASS\n$CONFIRM" | passwd "$USER" || return 1
  fi
  

  [[ "$SUDO" == "yes" ]] && {
    usermod -aG sudo "$USER"
    echo "Enabled sudo for $USER"
  }

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
