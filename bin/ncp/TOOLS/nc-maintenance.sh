#!/bin/bash

# Turn maintenance mode on or off
#
# Copyleft 2019 by Yi Chi 齊一 <chiyi4869 _a_t_ gmail _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at: https://www.cotpear.com
# Made in Taiwan (Republic of China)
#

configure()
{
  [[ $ACTIVE != "yes" ]] && {
    ncc maintenance:mode --off
    return 0 
  }
  ncc maintenance:mode --on 
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
