#!/bin/bash

# Unattended upgrades installation on NextcloudPi
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at: ownyourbits.com
#


install()
{
  apt-get update
  apt-get install -y --no-install-recommends unattended-upgrades
  rm -f /etc/apt/apt.conf.d/20auto-upgrades /etc/apt/apt.conf.d/02-armbian-periodic
}

configure()
{
  [[ $ACTIVE     == "yes" ]] && local AUTOUPGRADE=1   || local AUTOUPGRADE=0
  [[ $AUTOREBOOT == "yes" ]] && local AUTOREBOOT=true || local AUTOREBOOT=false

  cat > /etc/apt/apt.conf.d/20ncp-upgrades <<EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "$AUTOUPGRADE";
APT::Periodic::MaxAge "14";
APT::Periodic::AutocleanInterval "7";
Unattended-Upgrade::Automatic-Reboot "$AUTOREBOOT";
Unattended-Upgrade::Automatic-Reboot-Time "04:00";
Unattended-Upgrade::Origins-Pattern {
o=Debian,n=$RELEASE;
o=deb.sury.org,n=$RELEASE;
o="Raspberry Pi Foundation",n=$RELEASE;
o="Raspbian",n=$RELEASE;
}
Dpkg::Options {
   "--force-confdef";
   "--force-confold";
};

// Enable the update/upgrade script, disabled by Armbian in 02-armbian-periodic
APT::Periodic::Enable "1";
EOF

  echo "Unattended upgrades active: $ACTIVE (autoreboot $AUTOREBOOT)"
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

