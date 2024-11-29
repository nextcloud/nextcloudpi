#!/bin/bash

# Unmount and close external USB drive encrypted by LUKS
#
# Copyleft 2021 by Thomas Heller
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at: https://ownyourbits.com
#

install()
{
  apt-get install -y cryptsetup
  modprobe dm_mod
}

configure()
{
  [[ "$DEV" == "" ]] && {
    echo "error: please specify device"
    return 1
  }

  if [[ ! -e /media/USBdrive ]]; then
    echo "notice: /media/USBdrive is not yet mounted -- no need to unmount"
  else
    echo "unmounting /media/USBdrive ..."

    umount /media/USBdrive || {
      echo "unmount failed"
      return 2
    }
  fi

  echo "closing LUKS mapping ..."

  cryptsetup close nc || {
    echo "cryptsetup close failed"
    return 3
  }

  echo "ejecting $DEV ..."

  eject "$DEV" || {
    echo "eject failed"
    return 4
  }

  echo "successfully unmounted $DEV"
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
