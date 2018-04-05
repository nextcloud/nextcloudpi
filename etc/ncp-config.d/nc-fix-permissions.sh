#!/bin/bash

# Fix permissions of the data files, in case they were copied externally
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh nc-fix-permissions.sh <IP> (<img>)
#
# See installer.sh instructions for details
# More at: https://ownyourbits.com
#

DESCRIPTION="Fix permissions for NC data files, in case they were copied externally"

configure() 
{
  local DATADIR
  DATADIR=$( cd /var/www/nextcloud; sudo -u www-data php occ config:system:get datadirectory ) || {
    echo "data dir not found";
    return 1;
  }
  echo -ne "fixing permissions in $DATADIR... "
  chown -R www-data:www-data "$DATADIR"/*/files
  chmod -R u+rw              "$DATADIR"/*/files
  echo "done"
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
