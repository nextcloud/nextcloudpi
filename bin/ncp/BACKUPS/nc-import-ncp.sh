#!/bin/bash

# Import NextCloudPi configuration
#
#
# Copyleft 2017 by Courtney Hicks
# GPL licensed (see end of file) * Use at your own risk!
#



CFGDIR="/usr/local/etc/ncp-config.d"

configure()
{
  [[ -f "$FILE" ]] || { echo "export file $FILE does not exist"; return 1; }

  source /usr/local/etc/library.sh || return 1
  cd "$CFGDIR"   || return 1

  # extract export
  tar -xf "$FILE" -C "$CFGDIR"

  # UGLY workaround to prevent apache from restarting upon activating some extras
  # which leads to the operation appearing to fail in ncp-web
  #echo "invalid_op" >> /etc/apache2/sites-available/000-default.conf

  # activate
  # TODO

  # Fix invalid configuration
  #sed -i "/^invalid_op/d" /etc/apache2/sites-available/000-default.conf

  echo -e "\nconfiguration restored"

  # delayed in bg so it does not kill the connection, and we get AJAX response
  bash -c "sleep 2 && service apache2 reload" &>/dev/null &
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
