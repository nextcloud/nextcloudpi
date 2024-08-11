#!/bin/bash

# Import NextcloudPi configuration
#
#
# Copyleft 2017 by Courtney Hicks
# GPL licensed (see end of file) * Use at your own risk!
#




configure()
{
  [[ -f "$FILE" ]] || { echo "export file $FILE does not exist"; return 1; }

  cd "$CFGDIR"   || return 1

  # extract export
  tar -xf "$FILE" -C "$CFGDIR"

  # activate ncp-apps
  find "${CFGDIR}/" -name '*.cfg' | while read -r cfg; do
    app="$(basename "${cfg}" .cfg)"
    if [[ "${app}" == "letsencrypt" ]] || [[ "${app}" == "dnsmasq" ]]; then
      continue
    fi
    is_active_app "${app}" && run_app "${app}"
  done

  # order is important for these
  is_active_app "dnsmasq"     && run_app "dnsmasq"
  is_active_app "letsencrypt" && run_app "letsencrypt"

  echo -e "\nconfiguration restored"

  # delayed in bg so it does not kill the connection, and we get AJAX response
  apachectl -k graceful
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
