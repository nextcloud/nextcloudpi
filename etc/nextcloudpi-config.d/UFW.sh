#!/bin/bash

# Uncomplicated Firewall
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh UFW.sh <IP> (<img>)
#
# See installer.sh instructions for details
#
# More at https://ownyourbits.com/2017/02/13/nextcloud-ready-raspberry-pi-image/
#

ACTIVE_=no
HTTP_=80
HTTPS_=443
SSH_=22
DESCRIPTION="Uncomplicated Firewall"

INFO="Beware of blocking the SSH port you are using!"

install()
{
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ufw
  systemctl disable ufw
}

configure()
{
  [[ "$ACTIVE_" != yes ]] && {
    ufw --force reset
    systemctl disable ufw
    systemctl stop ufw
    echo "UFW disabled"
    return 0
  }
  ufw --force enable
  systemctl enable ufw
  systemctl start ufw

  echo "# web server rules"
  ufw allow $HTTP_/tcp
  ufw allow $HTTPS_/tcp
  ufw allow 4443/tcp

  echo "# SSH rules"
  ufw allow $SSH_

  echo "# DNS rules"
  ufw allow dns

  echo "# SAMBA rules"
  ufw allow samba

  echo "# NFS rules"
  ufw allow nfs

  echo "# UFW enabled"
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

