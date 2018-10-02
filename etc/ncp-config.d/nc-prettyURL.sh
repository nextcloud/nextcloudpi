#!/bin/bash
#
# Activate/deactivate a pretty URL without index.php
#
#
# Copyleft 2018 by Timo Stiefel and xxx
# GPL licensed (see end of file) * Use at your own risk!


ACTIVE_=no
DESCRIPTION="Set pretty URLs (no index.php in URL)"
INFOTITLE="PrettyURL notes"

NCDIR=/var/www/nextcloud
OCC="$NCDIR/occ"

install() { :; }

configure() 
{  
  # make sure overwrite.cli.url end with a '/'
  local URL="$(ncc config:system:get overwrite.cli.url)"
  [[ "${URL: -1}" != "/" ]] && ncc config:system:set overwrite.cli.url --value="${URL}/"

  [[ $ACTIVE_ != "yes" ]] && {
    sudo -u www-data php "$OCC" config:system:set htaccess.RewriteBase --value=""
    sudo -u www-data php "$OCC" maintenance:update:htaccess
    echo "Your cloud does no longer have a pretty domain name."
  } || {
    sudo -u www-data php "$OCC" config:system:set htaccess.RewriteBase --value="/"
    sudo -u www-data php "$OCC" maintenance:update:htaccess
    echo "Your cloud now has a pretty domain name."
  }
  bash -c "sleep 2 && service apache2 reload" &>/dev/null &
  return 0
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
