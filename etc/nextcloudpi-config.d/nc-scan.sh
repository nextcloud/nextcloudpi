#!/bin/bash

# Synchronize NextCloud for externally modified files
# Tested with 2017-03-02-raspbian-jessie-lite.img
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./nc-scan.sh
#
# See installer.sh instructions for details
# More at: https://ownyourbits.com
#

DESCRIPTION="Scan NC for externally modified files"

install() 
{ 
  cat > /usr/local/bin/ncp-scan <<EOF
#!/bin/bash
cd /var/www/nextcloud
sudo -u www-data php occ files:scan --all
EOF
  chmod +x /usr/local/bin/ncp-scan
}

configure() 
{
  /usr/local/bin/ncp-scan
}

cleanup() { :; }

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
