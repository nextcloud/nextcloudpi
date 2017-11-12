#!/bin/bash

# NextCloudPi installation script
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage: ./install.sh 
#
# more details at https://ownyourbits.com

#DBG=x

set -e$DBG

TMPDIR=/tmp/nextcloudpi

[[ ${EUID} -ne 0 ]] && {
  printf "Must be run as root. Try 'sudo $0'\n"
  exit 1
}

# check_distro 
grep -q -e "Debian GNU/Linux 9" -e "Raspbian GNU/Linux 9" /etc/issue || {
  echo "distro not supported"; 
  exit 1; 
}

# check installed software
type apache2 &>/dev/null && APACHE_EXISTS=1
type mysqld  &>/dev/null && echo ">>> WARNING: existing mysqld configuration will be changed <<<"

# get install code
echo "Getting build code..."
apt-get update
apt-get install --no-install-recommends -y wget ca-certificates sudo git

rm -rf "$TMPDIR"
git clone -q --depth 1 https://github.com/nextcloud/nextcloudpi.git "$TMPDIR" || exit 1
cd "$TMPDIR"

# install NCP
echo -e "\nInstalling NextCloudPi"
source etc/library.sh

install_script  lamp.sh
install_script  etc/nextcloudpi-config.d/nc-nextcloud.sh
activate_script etc/nextcloudpi-config.d/nc-nextcloud.sh
install_script  nextcloudpi.sh
activate_script etc/nextcloudpi-config.d/nc-init.sh

# re-enable mods disabled during install, in case there's other shared services in apache2
[[ "$APACHE_EXISTS" != "" ]] && \
  a2enmod status reqtimeout env autoindex access_compat auth_basic authn_file authn_core alias access_compat

# cleanup
cd -
rm -rf $TMPDIR

echo "Done. Type 'sudo nextcoludpi-config' to configure NCP"

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
