#!/bin/bash

# dnsmasq DNS server with cache installation on Raspbian 
# Tested with 2017-03-02-raspbian-jessie-lite.img
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh dnsmasq.sh <IP> (<img>)
#
# See installer.sh instructions for details
# More at: https://ownyourbits.com/2017/03/09/dnsmasq-as-dns-cache-server-for-nextcloudpi-and-raspbian/
#

DOMAIN_=mycloud.ownyourbits.com
IP_=127.0.0.1
DNSSERVER_=8.8.8.8
CACHESIZE_=150 
DESCRIPTION="dnsmasq: DNS server with cache"

install()
{
  apt-get update
  apt-get install -y dnsmasq
  update-rc.d dnsmasq disable
}

configure()
{
  cat > /etc/dnsmasq.conf <<EOF
domain-needed         # Never forward plain names (without a dot or domain part)
bogus-priv            # Never forward addresses in the non-routed address spaces.
no-poll               # Don't poll for changes in /etc/resolv.conf
no-resolv             # Don't use /etc/resolv.conf or any other file
cache-size=$CACHESIZE_ 
server=$DNSSERVER_
address=/$DOMAIN_/$IP_  # This is optional if we add it to /etc/hosts
EOF

  cat >> /etc/hosts <<EOF
$IP_ $DOMAIN_ # This is optional if we add it to dnsmasq.conf, but doesn't harm
EOF

  cat >> /etc/default/dnsmasq <<EOF
IGNORE_RESOLVCONF=yes
EOF
  update-rc.d dnsmasq defaults
  service dnsmasq restart
  cd /var/www/nextcloud
  sudo -u www-data php occ config:system:set trusted_domains 2 --value=$DOMAIN_
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

