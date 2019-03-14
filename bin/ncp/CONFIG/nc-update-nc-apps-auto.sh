#!/bin/bash

# Periodically update all installed Nextcloud Apps
#
# Copyleft 2019 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at: https://ownyourbits.com
#

configure() 
{
  local cronfile=/etc/cron.daily/ncp-autoupdate-apps

  [[ "$ACTIVE" != "yes" ]] && { 
    rm -f "$cronfile"
    echo "automatic app updates disabled"
    return 0
  }

  cat > "$cronfile" <<EOF
#!/bin/bash
OUT="\$(
echo "[ nc-update-nc-apps-auto ]"
echo "checking for updates..."
ncc app:update --all -n
)"
echo "\$OUT" >> /var/log/ncp.log

APPS=\$( echo "\$OUT" | grep 'updated\$' | awk '{ print \$1 }')
ncc notification:generate "$USER" "Apps updated" -l "\$APPS"
EOF
  chmod 755 "$cronfile"
  echo "automatic app updates enabled"
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

