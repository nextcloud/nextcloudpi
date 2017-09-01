#!/bin/bash

# Periodically synchronize NextCloud for externally modified files
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh nc-webui.sh <IP>
#
# See installer.sh instructions for details
# More at: https://ownyourbits.com
#

ACTIVE_=yes
DESCRIPTION="Enable or disable the NCP web interface"

configure() 
{
  if [[ $ACTIVE_ != "yes" ]]; then
    a2dissite ncp
    echo "ncp-web disabled"
  else
    a2ensite ncp
    echo "ncp-web enabled"
  fi

  # delayed in bg so it does not kill the connection, and we get AJAX response
  ( sleep 2 && systemctl restart apache2 ) &>/dev/null &
}

install() { :; }
cleanup() { :; }

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

