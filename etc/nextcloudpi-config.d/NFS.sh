#!/bin/bash

# NFS server for Raspbian 
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh NFS.sh <IP> (<img>)
#
# See installer.sh instructions for details
# More at: https://ownyourbits.com
#

ACTIVE_=no
DIR_=/media/USBdrive/ncdata/admin/files
SUBNET_=192.168.1.0/24
USER_=www-data
GROUP_=www-data
DESCRIPTION="NFS network file system server (for Linux LAN)"

INFOTITLE="Instructions for external synchronization"
INFO="If we intend to modify the data folder through NFS,
then we have to synchronize NextCloud to make it aware of the changes.

This can be done manually or automatically using 'nc-scan' and 'nc-scan-auto' 
from 'nextcloudpi-config'" 

install()
{
  apt-get update
  apt-get install --no-install-recommends -y nfs-kernel-server 
  systemctl disable nfs-kernel-server
  systemctl mask nfs-blkmap

  cat > /etc/systemd/system/nfs-common.services <<EOF
[Unit]
Description=NFS Common daemons
Wants=remote-fs-pre.target
DefaultDependencies=no

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/etc/init.d/nfs-common start
ExecStop=/etc/init.d/nfs-common stop

[Install]
WantedBy=sysinit.target
EOF

  cat > /etc/systemd/system/rpcbind.service <<EOF
[Unit]
Description=RPC bind portmap service
After=systemd-tmpfiles-setup.service
Wants=remote-fs-pre.target
Before=remote-fs-pre.target
DefaultDependencies=no

[Service]
ExecStart=/sbin/rpcbind -f -w
KillMode=process
Restart=on-failure

[Install]
WantedBy=sysinit.target
Alias=portmap
EOF
}

configure()
{
  [[ $ACTIVE_ != "yes" ]] && { 
    service nfs-kernel-server stop
    systemctl disable nfs-kernel-server
    echo -e "NFS disabled"
    return
  } 

  # CHECKS
  ################################
  id    "$USER_"  &>/dev/null || { echo "user USER_ does not exist"  ; return 1; }
  id -g "$GROUP_" &>/dev/null || { echo "group GROUP_ does not exist"; return 1; }
  [ -d "$DIR_" ] || { echo -e "INFO: directory $DIR_ does not exist. Creating"; mkdir -p "$DIR_"; }
  [[ $( stat -fc%d / ) == $( stat -fc%d $DIR_ ) ]] && \
    echo -e "INFO: mounting a in the SD card\nIf you want to use an external mount, make sure it is properly set up"

  # CONFIG
  ################################
  cat > /etc/exports <<EOF
$DIR_ $SUBNET_(rw,sync,all_squash,anonuid=$(id -u $USER_),anongid=$(id -g $GROUP_),no_subtree_check)
EOF

  systemctl enable rpcbind
  systemctl enable nfs-kernel-server
  service nfs-kernel-server restart
  echo -e "NFS enabled"
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
