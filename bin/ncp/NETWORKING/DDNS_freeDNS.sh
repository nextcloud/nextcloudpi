#!/bin/bash

# FreeDNS updater client installation on Raspbian 
#
# Copyleft 2017 by Panteleimon Sarantos <pantelis.fedora _a_t_ gmail _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#


UPDATEURL=https://freedns.afraid.org/dynamic/update.php
URL="${UPDATEURL}?${UPDATEHASH}"

install()
{
  apt-get update
  apt-get install --no-install-recommends -y dnsutils
}

configure() 
{
  [[ $ACTIVE != "yes" ]] && { 
    rm -f /etc/cron.d/freeDNS
    service cron restart
    echo "FreeDNS client is disabled"
    return 0
  }

  cat > /usr/local/bin/freedns.sh <<EOF
#!/bin/bash
echo "FreeDNS client started"
echo "${URL}"
registeredIP=$(dig +short "$DOMAIN"|tail -n1)
currentIP=\$(wget -q -O - http://checkip.dyndns.org|sed s/[^0-9.]//g)
    [ "\$currentIP" != "\$registeredIP" ] && {
        wget -q -O /dev/null ${URL}
  }
echo "Registered IP: \$registeredIP | Current IP: \$currentIP"
EOF
  chmod +744 /usr/local/bin/freedns.sh

  echo "*/${UPDATEINTERVAL}  *  *  *  *  root  /bin/bash /usr/local/bin/freedns.sh" > /etc/cron.d/freeDNS
  service cron restart

  cd /var/www/nextcloud
  sudo -u www-data php occ config:system:set trusted_domains 3 --value="$DOMAIN"
  sudo -u www-data php occ config:system:set overwrite.cli.url --value=https://"$DOMAIN"/

  echo "FreeDNS client is enabled"
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
