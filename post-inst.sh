#!/bin/bash

# Cleanup step NCP image
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at nextcloudpi.com
#

configure()
{
(
  set +e

  # stop services
  systemctl stop redis
  [[ -f /run/mysqld/mysqld.pid ]] && mysqladmin -u root shutdown
  [[ -f /run/crond.pid ]]     && kill "$(cat /run/crond.pid)"
  pkill -f php-fpm
  pkill -f notify_push
  killall postdrop
  killall sendmail

  [[ -f /usr/local/etc/ncp-config.d/SSH.cfg ]] && systemctl disable ssh

  # cleanup all NCP extras
  find /usr/local/bin/ncp -name '*.sh' | \
    while read script; do cleanup_script $script; done

  # clean packages and installation logs
  apt-get autoremove -y
  apt-get clean
  rm /var/lib/apt/lists/* -r
  find /var/log -type f -exec rm {} \;

  # clean build flags
  rm -f /.ncp-image
)
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
