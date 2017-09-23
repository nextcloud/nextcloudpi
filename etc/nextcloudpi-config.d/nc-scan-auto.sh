#!/bin/bash

# Periodically synchronize NextCloud for externally modified files
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./nc-scan-auto.sh
#
# See installer.sh instructions for details
# More at: https://ownyourbits.com
#

ACTIVE_=no
SCANINTERVAL_=60
DESCRIPTION="Periodically scan NC for externally modified files"

INFOTITLE="Instructions for auto synchronization"
INFO="Set the time in minutes in SCANINTERVAL.

>>> If there are too many files this can greatly affect performance. <<<"

install() 
{
  cat > /etc/systemd/system/nc-scan.service <<EOF
[Unit]
Description=Scan NC for externally modified files

[Service]
Type=simple
ExecStart=/usr/local/bin/ncp-scan

[Install]
WantedBy=default.target
EOF
}

configure() 
{
    [[ $ACTIVE_ != "yes" ]] && { 
    systemctl stop    nc-scan.timer
    systemctl disable nc-scan.timer
    echo "automatic scans disabled"
    return 0
  }

  cat > /etc/systemd/system/nc-scan.timer <<EOF
[Unit]
Description=Timer to scan NC for externally modified files

[Timer]
OnBootSec=${SCANINTERVAL_}min
OnUnitActiveSec=${SCANINTERVAL_}min
Unit=nc-scan.service

[Install]
WantedBy=timers.target
EOF

  systemctl daemon-reload
  systemctl enable nc-scan.timer
  systemctl start  nc-scan.timer
  echo "automatic scans enabled"
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

