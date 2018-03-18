#!/bin/bash

# Cleanup step Raspbian image
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh raspbian-cleanup.sh <IP> (<img>)
#
# See installer.sh instructions for details
#
# More at https://ownyourbits.com/2017/02/13/nextcloud-ready-raspberry-pi-image/
#

install()   { :; }
configure() { :; }

cleanup()   
{ 
  # cleanup all NCP extras
  source /usr/local/etc/library.sh
  cd /usr/local/etc/nextcloudpi-config.d/
  for script in *.sh; do
    cleanup_script $script
  done

  # clean packages
  apt-get autoremove -y
  apt-get clean
  rm /var/lib/apt/lists/* -r

  # restore expand filesystem on first boot
  cat > /etc/init.d/resize2fs_once <<'EOF'
#!/bin/sh
### BEGIN INIT INFO
# Provides:          resize2fs_once
# Required-Start:
# Required-Stop:
# Default-Start: 3
# Default-Stop:
# Short-Description: Resize the root filesystem to fill partition
# Description:
### END INIT INFO

. /lib/lsb/init-functions

case "$1" in
  start)
    log_daemon_msg "Starting resize2fs_once" && \
    resize2fs /dev/mmcblk0p2 && \
    update-rc.d resize2fs_once remove && \
    rm /etc/init.d/resize2fs_once && \
    log_end_msg $?
    ;;
  *)
    echo "Usage: $0 start" >&2
    exit 3
    ;;
esac
EOF
  chmod +x /etc/init.d/resize2fs_once
  systemctl enable resize2fs_once

  # remove QEMU specific rules
  rm -f /etc/udev/rules.d/90-qemu.rules

  # clean build flags
  rm /.ncp-image

  # disable SSH
  systemctl disable ssh

  # enable randomize passwords
  systemctl enable nc-provisioning
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
