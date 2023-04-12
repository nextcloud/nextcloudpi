#!/bin/bash

# Synchronize Nextcloud for externally modified files
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at: https://ownyourbits.com
#


install()
{
  cat > /usr/local/bin/ncp-scan <<'EOF'
#!/bin/bash
ncc files:scan -n -v --all
EOF
  chmod +x /usr/local/bin/ncp-scan
}

configure()
{
  grep -q enabled <(ncc maintenance:mode) && { echo "Cannot run ncp-scan while in maintenance mode"; exit 1; }

  local ret=0

  [[ "$RECURSIVE"   == no  ]] && local recursive=--shallow
  [[ "$NONEXTERNAL" == yes ]] && local non_external=--home-only

  [[ "$PATH1" != "" ]] && {
    ncc files:scan -n -v $recursive $non_external -p "$PATH1"
    [[ $? -ne 0 ]] && ret=1
  }

  [[ "$PATH2" != "" ]] && {
    ncc files:scan -n -v $recursive $non_external -p "$PATH2"
    [[ $? -ne 0 ]] && ret=1
  }

  [[ "$PATH3" != "" ]] && {
    ncc files:scan -n -v $recursive $non_external -p "$PATH3"
    [[ $? -ne 0 ]] && ret=1
  }

  [[ "${PATH1}${PATH2}${PATH3}" == "" ]] && {
    ncc files:scan -n -v $recursive $non_external --all
    [[ $? -ne 0 ]] && ret=1
  }

  return ${ret}
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
