#!/bin/bash

# Automatically apply Nextcloud updates
#
# Copyleft 2018 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at: https://ownyourbits.com
#

# just change NCLATESTVER and re-activate in update.sh to upgrade users

tmpl_ncp_update_nc_args() {

  CHECK_INCOMPATIBLE_APPS="$(
    . /usr/local/etc/library.sh
    find_app_param nc-autoupdate-nc CHECK_INCOMPATIBLE_APPS
  )"
  if [[ "${CHECK_INCOMPATIBLE_APPS:-yes}" != "yes" ]]
  then
    echo "--allow-incompatible-apps"
  fi

}

configure()
{
  [[ "$ACTIVE" != "yes" ]] && {
    rm -f /etc/cron.daily/ncp-autoupdate-nc
    echo "automatic Nextcloud updates disabled"
    return 0
  }

  install_template cron.daily/ncp-autoupdate-nc.sh "/etc/cron.daily/ncp-autoupdate-nc"
  chmod 755 /etc/cron.daily/ncp-autoupdate-nc
  echo "automatic Nextcloud updates enabled"
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

