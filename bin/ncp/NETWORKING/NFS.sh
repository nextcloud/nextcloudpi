#!/bin/bash

# NFS server for Raspbian 
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at: https://ownyourbits.com
#


install()
{
  apt-get update
  apt-get install --no-install-recommends -y nfs-kernel-server 
  systemctl disable nfs-kernel-server
  systemctl mask nfs-blkmap

  # delay init because of automount
  sed -i 's|^ExecStartPre=.*|ExecStartPre=/bin/bash -c "/bin/sleep 30; /usr/sbin/exportfs -r"|' /lib/systemd/system/nfs-server.service
}

configure()
{
  [[ $ACTIVE != "yes" ]] && { 
    service nfs-kernel-server stop
    systemctl disable nfs-kernel-server
    echo -e "NFS disabled"
    return
  } 

  # CHECKS
  ################################
  id    "$USER"  &>/dev/null || { echo "user $USER does not exist"  ; return 1; }
  id -g "$GROUP" &>/dev/null || { echo "group $GROUP does not exist"; return 1; }
  [ -d "$DIR" ] || { echo -e "INFO: directory $DIR does not exist. Creating"; mkdir -p "$DIR"; }
  [[ $( stat -fc%d / ) == $( stat -fc%d $DIR ) ]] && \
    echo -e "INFO: mounting a in the SD card\nIf you want to use an external mount, make sure it is properly set up"

  # CONFIG
  ################################
  cat > /etc/exports <<EOF
$DIR $SUBNET(rw,sync,all_squash,anonuid=$(id -u $USER),anongid=$(id -g $GROUP),no_subtree_check)
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
