#!/bin/bash

# Automount configuration for NextcloudPi
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at https://ownyourbits.com/
#


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
Before=mysqld.service dphys-swapfile.service fail2ban.service smbd.service nfs-server.service

[Service]
Restart=always
ExecStartPre=/bin/bash -c "rmdir /media/* || true"
ExecStart=/usr/bin/udiskie -NTFv

[Install]
WantedBy=multi-user.target
EOF

  cat > /usr/lib/systemd/system/nc-automount-links.service <<'EOF'
[Unit]
Description=Monitor /media for mountpoints and create USBdrive* symlinks
Before=nc-automount.service

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
      test -e /media/USBdrive   || test -d "$d" && ln -sT "$d" /media/USBdrive
    else
      test -e /media/USBdrive$i || test -d "$d" && ln -sT "$d" /media/USBdrive$i
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
}

configure()
{
  [[ $ACTIVE != "yes" ]] && {
    systemctl disable --now nc-automount
    systemctl disable --now nc-automount-links
    rm -rf /etc/systemd/system/{mariadb,nfs-server,dphys-swapfile,fail2ban}.service.d
    systemctl daemon-reload
    echo "automount disabled"
    return 0
  }
  systemctl enable  --now nc-automount
  systemctl enable  --now nc-automount-links

  # create delays in some units
  mkdir -p /etc/systemd/system/mariadb.service.d
  cat > /etc/systemd/system/mariadb.service.d/ncp-delay-automount.conf <<'EOF'
[Service]
ExecStartPre=/bin/sleep 20
Restart=on-failure
EOF

  mkdir -p /etc/systemd/system/nfs-server.service.d
  cat > /etc/systemd/system/nfs-server.service.d/ncp-delay-automount.conf <<'EOF'
[Service]
ExecStartPre=
ExecStartPre=/bin/bash -c "/bin/sleep 30; /usr/sbin/exportfs -r"
EOF

  mkdir -p /etc/systemd/system/dphys-swapfile.service.d
  cat > /etc/systemd/system/dphys-swapfile.service.d/ncp-delay-automount.conf <<'EOF'
[Service]
ExecStartPre=/bin/sleep 30
EOF

  mkdir -p /etc/systemd/system/fail2ban.service.d
  cat > /etc/systemd/system/fail2ban.service.d/ncp-delay-automount.conf <<'EOF'
[Service]
ExecStartPre=/bin/sleep 10
EOF

  systemctl daemon-reload
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

