#!/bin/bash

# Change password for the ncp-web user
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at: https://ownyourbits.com
#

configure()
{
  # update password
  echo -e "$PASSWORD\n$CONFIRM" | passwd ncp &>/dev/null && \
    echo "password updated successfully" || \
    { echo "passwords do not match"; return 1; }

  # persist ncp-web password in docker container
  [[ -f /.docker-image ]] && {
    mv /etc/shadow /data/etc/shadow
    ln -s /data/etc/shadow /etc/shadow
  }

  # activate NCP
  if ! is_ncp_activated; then
    # Run cron.php once now to get all checks right in CI.
    sudo -u www-data php /var/www/nextcloud/cron.php

    a2dissite ncp-activation
    a2ensite  ncp 001-nextcloud
    apachectl -k graceful
    sed -i -e 's/^NCP is not activated yet.*$//' /etc/issue

    # Trusted Domain (local/public IP), also configures notify_push
    bash /usr/local/bin/nextcloud-domain.sh
  fi
}

install() { :; }

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
