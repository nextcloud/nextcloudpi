#!/bin/bash

# Periodically system standby and wakeup
#
# Copyleft 2020 by Alessandro Dolci <dolci _d_o_t_ alessandro94 _a_t_ gmail _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#

configure()
{
  local cronfile=/etc/cron.d/standby-auto

  if [[ "$ACTIVE" != "yes" ]]; then
    # Disable cron job
    rm -f $cronfile
    service cron restart

    echo "Automatic standby disabled"
  else
    # Prevent spaces
    local min=$(echo "$MIN" | awk '{print $1;}')
    local hour=$(echo "$HOUR"| awk '{print $1;}')

    # Create cron job
    echo "${min} ${hour} * * * root /usr/sbin/rtcwake -m '${MODE}' -s '$(( DURATION * 60   ))'" > $cronfile
    chmod 644 $cronfile
    service cron restart

    echo "Automatic standby enabled"
  fi
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

