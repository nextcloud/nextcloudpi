#!/bin/bash

# no-ip.org installation on Raspbian 
# Tested with 2017-03-02-raspbian-jessie-lite.img
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh no-ip.sh <IP> (<img>)
#
# See installer.sh instructions for details
#

USER_=my-noip-user@email.com
PASS_=noip-pass
TIME_=30
DESCRIPTION="no-ip.org: free Dynamic DNS provider (need account)"

install()
{
  mkdir /tmp/noip && cd /tmp/noip
  wget http://www.no-ip.com/client/linux/noip-duc-linux.tar.gz
  tar vzxf noip-duc-linux.tar.gz
  cd -; cd $OLDPWD/noip-*
  make
  cp noip2 /usr/local/bin/

  cat > /etc/init.d/noip2 <<'EOF'
#! /bin/sh
# /etc/init.d/noip2

### BEGIN INIT INFO
# Provides:          no-ip.org
# Required-Start:    $local_fs $remote_fs
# Required-Stop:     $local_fs $remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start no-ip.org dynamic DNS
### END INIT INFO
EOF

  cat debian.noip2.sh >> /etc/init.d/noip2 

  chmod +x /etc/init.d/noip2
  cd -
  rm -r /tmp/noip
}

configure() 
{
  /usr/local/bin/noip2 -C -c /usr/local/etc/no-ip2.conf -U $TIME_ -u $USER_ -p $PASS_
  update-rc.d noip2 defaults
  service noip2 restart
}

cleanup()
{
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

