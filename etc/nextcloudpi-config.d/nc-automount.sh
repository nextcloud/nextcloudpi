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

INFOTITLE="Automount notes"
INFO="Plugged in USB drives will be automounted under /media
on boot or at the moment of insertion.

Format your drive as ext4 in order to move NC datafolder or database
VFAT or NTFS is not recommended for this task, as it does not suport permissions

IMPORTANT: halt or umount the drive before extracting"

install()
{
  apt-get update
  apt-get install -y --no-install-recommends udiskie inotify-tools

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

[Install]
WantedBy=multi-user.target
EOF

  cat > /usr/lib/systemd/system/nc-automount-links.service <<'EOF'
[Unit]
Description=Monitor /media for mountpoints and create USBdrive* symlinks

[Service]
Restart=always
ExecStart=/usr/local/etc/nc-automount-links-mon

[Install]
WantedBy=multi-user.target
EOF

  cat > /usr/local/etc/nc-automount-links <<'EOF'
#!/bin/bash

ls -d /media/* &>/dev/null && {

  # remove old links
  for l in $( ls /media/ ); do
    test -L /media/"$l" && rm /media/"$l"
  done

  # create links
  i=0
  for d in $( ls -d /media/* 2>/dev/null ); do
    if [ $i -eq 0 ]; then
      [[ -e /media/USBdrive   ]] || mountpoint -q "$d" && ln -sT "$d" /media/USBdrive
    else
      [[ -e /media/USBdrive$i ]] || mountpoint -q "$d" && ln -sT "$d" /media/USBdrive$i
    fi
    i=$(( i + 1 ))
  done

}
EOF
  chmod +x /usr/local/etc/nc-automount-links

  cat > /usr/local/etc/nc-automount-links-mon <<'EOF'
#!/bin/bash
inotifywait --monitor --event create --event delete --format '%f %e' /media/ | \
  grep --line-buffered ISDIR | while read f; do
    echo $f
    sleep 0.5
    /usr/local/etc/nc-automount-links
done
EOF
  chmod +x /usr/local/etc/nc-automount-links-mon

  # adjust when mariaDB starts
  local DBUNIT=/lib/systemd/system/mariadb.service
  grep -q sleep $DBUNIT  || sed -i "/^ExecStart=/iExecStartPre=/bin/sleep 10" $DBUNIT

  systemctl daemon-reload
}

configure()
{
  [[ $ACTIVE_ != "yes" ]] && {
    systemctl stop    nc-automount
    systemctl stop    nc-automount-links
    systemctl disable nc-automount
    systemctl disable nc-automount-links
    echo "automount disabled"
    return 0
  }
  systemctl enable  nc-automount
  systemctl enable  nc-automount-links
  systemctl start   nc-automount
  systemctl start   nc-automount-links
  echo "automount enabled"
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

