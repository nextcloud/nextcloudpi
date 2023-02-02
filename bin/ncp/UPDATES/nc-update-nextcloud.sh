#!/bin/bash

# Update current instance to a new Nextcloud version
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at https://ownyourbits.com/2017/02/13/nextcloud-ready-raspberry-pi-image/
#

LATEST="$NCLATESTVER"

configure()
{
  [[ "$VERSION" == "0" ]] && VERSION="$LATEST"
  if ! is_docker && ! is_more_recent_than "24.0.0" "${VERSION}" && is_more_recent_than "8.1.0" "${PHPVER}.0" && [[ " ${BASH_SOURCE[*]} " =~ .*" /home/www/ncp-launcher.sh ".* ]]
    then
      echo "We need to upgrade PHP. This process cannot be performed from the web UI. Please use 'ncp-config' from the terminal (via SSH or direct access) to update Nextcloud instead. Future updates can again be run from the web UI"
      exit 1
    fi
  bash /usr/local/bin/ncp-update-nc "$VERSION"
}

install() { :; }

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

