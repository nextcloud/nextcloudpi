#!/bin/bash

# NextCloudPi ZRAM settings
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh nc-zram.sh <IP> (<img>)
#
# See installer.sh instructions for details
#
# More at https://ownyourbits.com/2017/02/13/nextcloud-ready-raspberry-pi-image/
#

ACTIVE_=no
DESCRIPTION="Enable compressed RAM to improve swap performance"

install()
{
  cat > /etc/systemd/system/zram.service <<EOF
[Unit]
Description=Set up ZRAM

[Service]
Type=oneshot
ExecStart=/usr/local/bin/ncp-zram start
ExecStop=/usr/local/bin/ncp-zram  stop
RemainAfterExit=yes

[Install]
WantedBy=sysinit.target
EOF

cat > /usr/local/bin/ncp-zram <<'EOF'
#!/bin/bash
# inspired by https://github.com/novaspirit/rpi_zram/blob/master/zram.sh

case "$1" in
  start)
      CORES=$(nproc --all)
      modprobe zram num_devices=$CORES || exit 1

      swapoff -a

      TOTALMEM=`free | grep -e "^Mem:" | awk '{print $2}'`
      MEM=$(( ($TOTALMEM / $CORES)* 1024 ))

      core=0
      while [ $core -lt $CORES ]; do
        echo $MEM > /sys/block/zram$core/disksize
        mkswap /dev/zram$core
        swapon -p 5 /dev/zram$core
        let core=core+1
      done
      ;;

  stop)
      swapoff -a
      rmmod zram
      ;;
  *)
      echo "Usage: $0 {start|stop}" >&2
      exit 1
      ;;
esac
EOF
chmod +x /usr/local/bin/ncp-zram
}

configure()
{
  [[ $ACTIVE_ != "yes" ]] && { 
    systemctl stop    zram
    systemctl disable zram
    echo "ZRAM disabled"
    return 0
  }
  systemctl start  zram
  systemctl enable zram
  echo "ZRAM enabled"
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

