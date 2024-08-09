#!/bin/bash

# Manually add trusted proxies in NextcloudPi
#
# Copyleft 2019 by Pascal Haefliger <45995338+paschaef_a_t_users_d_o_t_noreply_d_o_tgithub_d_o_t_com>
# GPL licensed (see end of file) * Use at your own risk!
#
#

configure()
{
  [[ "$PROXY1" != "" ]] && ncc config:system:set trusted_proxies 0 --value="$PROXY1"
  [[ "$PROXY2" != "" ]] && ncc config:system:set trusted_proxies 1 --value="$PROXY2"
  [[ "$PROXY3" != "" ]] && ncc config:system:set trusted_proxies 2 --value="$PROXY3"

  exit 0
}

install(){ :; }

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

