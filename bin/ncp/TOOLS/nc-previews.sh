#!/bin/bash

# Generate previews for the gallery
#
# Copyleft 2018 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at nextcloudpi.com
#


configure()
{
  [[ "$CLEAN" == "yes" ]] && {
    local datadir
    datadir=$( ncc config:system:get datadirectory ) || {
      echo "data directory not found";
      return 1;
    }

    rm -r "$datadir"/appdata_*/preview/* &>/dev/null
    mysql nextcloud <<<"delete from oc_filecache where path like \"appdata_%/preview/%\""
    ncc files:scan-app-data -n
  }

  [[ "$INCREMENTAL" == "yes" ]] && { ncc preview:pre-generate -n -vvv; return $?; }

  ncc preview:generate-all -n -v -p "$PATH1"
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

