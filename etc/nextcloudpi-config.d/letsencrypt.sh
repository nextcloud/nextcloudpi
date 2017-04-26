#!/bin/bash

# Let's encrypt certbot installation on Raspbian 
# Tested with 2017-03-02-raspbian-jessie-lite.img
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh letsencrypt.sh <IP> (<img>)
#
# See installer.sh instructions for details
#
# More at https://ownyourbits.com/2017/03/17/lets-encrypt-installer-for-apache/

DOMAIN_=mycloud.ownyourbits.com
EMAIL_=mycloud@ownyourbits.com
VHOSTCFG_=/etc/apache2/sites-available/nextcloud.conf
DESCRIPTION="Automatic signed SSL certificates"

install()
{
  cd /etc
  git clone https://github.com/letsencrypt/letsencrypt
  /etc/letsencrypt/letsencrypt-auto --help # do not actually run certbot, only install packages
}

# tested with git version v0.11.0-71-g018a304
configure() 
{
  grep -q ServerName $VHOSTCFG_ && \
    sed -i "s|ServerName .*|ServerName $DOMAIN_|" $VHOSTCFG_ || \
    sed -i "/DocumentRoot/aServerName $DOMAIN_" $VHOSTCFG_ 

  /etc/letsencrypt/letsencrypt-auto -n --no-self-upgrade --apache --hsts --agree-tos -m $EMAIL_ -d $DOMAIN_
  echo "* 1 * * 1 root /etc/letsencrypt/certbot-auto renew --quiet" > /etc/cron.d/letsencrypt-ncp
  service apache2 reload
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

