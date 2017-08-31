#!/bin/bash

# Automount configuration for NextCloudPi
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh nc-automount.sh <IP> (<img>)
#
# See installer.sh instructions for details
#
# More at https://ownyourbits.com/
#

ACTIVE_=no
DESCRIPTION="Automount USB drives by plugging them in"

show_info()
{
  whiptail --yesno \
           --backtitle "NextCloudPi configuration" \
           --title "Automount notes" \
"Plugged in USB drives will be automounted under /media
on boot or at the moment of insertion.

Format your drive as ext4 in order to move NC datafolder or database
VFAT or NTFS is not recommended for this task, as it does not suport permissions

Drives with multiple partitions are not supported

IMPORTANT: halt or umount the drive before extracting" \
  20 90
}

install()
{
  apt-get update
  apt-get install -y --no-install-recommends udiskie

  cat > /etc/udev/rules.d/99-udisks2.rules <<'EOF'
ENV{ID_FS_USAGE}=="filesystem|other|crypto", ENV{UDISKS_FILESYSTEM_SHARED}="1"
EOF

  cat > /usr/lib/systemd/system/nc-automount.service <<'EOF'
[Unit]
Description=Automount USB drives
Before=mysqld.service

[Service]
Restart=always
ExecStart=/usr/bin/udiskie -NTF
ExecStartPost=/bin/sleep 8
ExecStartPost=/usr/local/etc/nc-automount-links

[Install]
WantedBy=multi-user.target
EOF

  cat > /usr/local/etc/nc-automount-links <<'EOF'
#!/bin/bash

ls -d /media/* &>/dev/null && {

  # remove old links
  for l in `ls /media/`; do
    test -L /media/"$l" && rm /media/"$l"
  done

  # create links
  i=0
  for d in `ls -d /media/*`; do
    [ $i -eq 0 ] && \
      ln -sT "$d" /media/USBdrive   || \
      ln -sT "$d" /media/USBdrive$i
    i=$(( i + 1 ))
  done
}
EOF
  chmod +x /usr/local/etc/nc-automount-links

  # adjust when mariaDB starts
  local DBUNIT=/lib/systemd/system/mariadb.service
  grep -q sleep $DBUNIT  || sed -i "/^ExecStart=/iExecStartPre=/bin/sleep 10" $DBUNIT
}

configure()
{
  [[ $ACTIVE_ != "yes" ]] && {
    systemctl stop    nc-automount
    systemctl disable nc-automount
    echo "automount disabled"
    return 0
  }
  systemctl enable  nc-automount
  systemctl start   nc-automount
  echo "automount enabled"
}

cleanup()
{
  apt-get autoremove -y
  apt-get clean
  rm /var/lib/apt/lists/* -r
  rm -f /home/pi/.bash_history
  systemctl disable ssh
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

