#!/bin/bash

# Activate/deactivate SSH
#
#
# Copyleft 2017 by Courtney Hicks and Ignacio Nunez Hernanz
# GPL licensed (see end of file) * Use at your own risk!
#


install() {
  apt-get update
  apt-get install -y --no-install-recommends openssh-server
  if grep '^PermitRootLogin' /etc/ssh/sshd_config
  then
    sed -i -e 's/^PermitRootLogin.*$/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
  else
    echo 'PermitRootLogin prohibit-password' >> /etc/ssh/sshd_config
  fi
  systemctl reload ssh
 }

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

  # --force: exit successfully if the group already exists
  groupadd --force ncp-ssh

  # Change or create credentials
  if id "$USER" &>/dev/null
  then
    usermod --append --groups ncp-ssh "$USER"
    echo "$USER exists, changing password"
    echo -e "$PASS\n$CONFIRM" | passwd "$USER" || return 1
    # Unlocks the user if previously locked
    # This one needs to be after passwd becuase it will fail
    # if the user didn't have a password set when the account was locked
    usermod --unlock --expiredate -1 "$USER"
  else
    echo "Creating $USER & setting password"
    useradd --create-home --home-dir /home/"$USER" --shell /bin/bash --groups ncp-ssh "$USER" || return 1
    echo -e "$PASS\n$CONFIRM" | passwd "$USER" || return 1
  fi

  # Get the current users of the group to an array
  mapfile -d ',' -t GROUP_USERS < <(awk -F':' '/ncp-ssh/{printf $4}' /etc/group)

  if [[ "${#GROUP_USERS[@]}" -gt 0 ]]
  then
    # Loop through each user in the group
    for U in "${GROUP_USERS[@]}"
    do
      # Test if extra users exists in the group
      if [[ "$U" != "$USER" ]]
      then
        echo "Disabling user '$U'..."
        # Locks any extra accounts
        usermod --lock --expiredate 1 "$U"
      fi
    done
  fi

  # Unsets the group array variable (cleanup)
  unset GROUP_USERS

  [[ "$SUDO" == "yes" ]] && {
    usermod --append --groups sudo "$USER"
    echo "Enabled sudo for $USER"
  }

  # Enable
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
