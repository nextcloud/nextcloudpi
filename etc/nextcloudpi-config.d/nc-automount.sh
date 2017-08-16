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
  cat >> /etc/fstab <<EOF

# Rules for automounting both at boot and upon USB plugin. Rely on udev rules
/dev/USBdrive  /media/USBdrive         auto    defaults,noatime,auto,nofail    0       2
/dev/USBdrive1 /media/USBdrive1        auto    defaults,noatime,auto,nofail    0       2
/dev/USBdrive2 /media/USBdrive2        auto    defaults,noatime,auto,nofail    0       2
/dev/USBdrive3 /media/USBdrive3        auto    defaults,noatime,auto,nofail    0       2
/dev/USBdrive4 /media/USBdrive4        auto    defaults,noatime,auto,nofail    0       2
/dev/USBdrive5 /media/USBdrive5        auto    defaults,noatime,auto,nofail    0       2
/dev/USBdrive6 /media/USBdrive6        auto    defaults,noatime,auto,nofail    0       2
/dev/USBdrive7 /media/USBdrive7        auto    defaults,noatime,auto,nofail    0       2
/dev/USBdrive8 /media/USBdrive8        auto    defaults,noatime,auto,nofail    0       2
EOF

  cat > /usr/local/etc/blknum <<'EOF'
#!/bin/bash

# we perform a cleanup with the first one
ls -d /dev/USBdrive* &>/dev/null || {
  rmdir /media/USBdrive*
  for f in `ls /media/`; do
    test -L $f && rm $f
  done
  exit 0
}

for i in `seq 1 1 8`; do
  test -e /media/USBdrive$i && continue
  echo $i
  exit 0
done

exit 1
EOF
  chmod +x /usr/local/etc/blknum

  systemctl daemon-reload
}

cleanup() { :; }

configure()
{
  cat > /etc/udev/rules.d/50-automount.rules <<'EOF'
# Need to be a block device
KERNEL!="sd[a-z][0-9]", GOTO="exit"

# Import some useful filesystem info as variables
IMPORT{program}="/sbin/blkid -o udev -p %N"

# Need to be a filesystem
ENV{ID_FS_TYPE}!="vfat|ntfs|ext4|iso9660", GOTO="exit"

# Create symlink that will be understood by fstab, and a directory in /media
ACTION!="remove", PROGRAM="/usr/local/etc/blknum", RUN+="/bin/mkdir -p /media/USBdrive%c", SYMLINK+="USBdrive%c"

# Get a label if present, otherwise specify one
ENV{ID_FS_LABEL}!="", ENV{dir_name}="%E{ID_FS_LABEL}"

# Link with label name if exists
ACTION=="add", ENV{ID_FS_LABEL}!="", ENV{ID_FS_LABEL}!="USBdrive*", RUN+="/bin/rm /media/%E{ID_FS_LABEL}", RUN+="/bin/ln -sT /media/USBdrive%c /media/%E{ID_FS_LABEL}"

# Exit
LABEL="exit"
EOF

  [[ "$ACTIVE_" != "yes" ]] && rm -f /etc/udev/rules.d/50-automount.rules

  # mount whatever is currently plugged in
  udevadm control --reload-rules && udevadm trigger

  [[ "$ACTIVE_" != "yes" ]] && echo "automount is now inactive" || echo "automount is now active"
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

