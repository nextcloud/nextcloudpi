#!/bin/bash

# Automatically apply NextcloudPi updates
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at: https://ownyourbits.com
#


configure()
{
  [[ $ACTIVE != "yes" ]] && { 
    rm -f /etc/cron.daily/ncp-autoupdate
    echo "automatic NextCloudPi updates disabled"
    return 0
  }

  cat > /etc/cron.daily/ncp-autoupdate <<EOF
#!/bin/bash
source /usr/local/etc/library.sh
# Forward all output to the ncp log
exec >> /var/log/ncp.log 2>&1
echo "\$(date) - Running \$0..."
if /usr/local/bin/ncp-test-updates; then
  /usr/local/bin/ncp-update || exit 1
  notify_admin "NextCloudPi" "NextCloudPi was updated to \$(cat /usr/local/etc/ncp-version)"
fi
EOF
  chmod 755 /etc/cron.daily/ncp-autoupdate
  echo "automatic NextCloudPi updates enabled"
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

