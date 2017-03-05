#!/bin/bash

# no-ip.org installation on Raspbian 
# Tested with 2017-01-11-raspbian-jessie.img (and lite)
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
#   cat no-ip.sh | ssh pi@$IP
#
#   , or scp this file to a Raspberry Pi and run it from Raspbian
#
#   ./no-ip.sh
#
# Notes:
#   Note that you need internet access for the installation to register with no-ip.org
#

set -xe

sudo su

USER_=my-noip-user@email.com
PASS_=noip-pass
TIME_=30

set -xe

# INSTALLATION
##########################################

mkdir /tmp/noip && cd /tmp/noip
wget http://www.no-ip.com/client/linux/noip-duc-linux.tar.gz
tar vzxf noip-duc-linux.tar.gz
cd noip-*
sed -i "31s=^.*$=\t/usr/local/bin/noip2 -C -c /tmp/no-ip2.conf -U $TIME_ -u $USER_ -p $PASS_=" Makefile
make
make install

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
update-rc.d noip2 defaults
cd 
rm -r /tmp/noip

# CLEANUP
##########################################

rm -f /home/pi/.bash_history
systemctl disable ssh
halt

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

