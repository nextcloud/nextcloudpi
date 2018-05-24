#!/bin/bash

# FreeDNS updater client installation on Raspbian 
#
# Copyleft 2017 by Panteleimon Sarantos <pantelis.fedora _a_t_ gmail _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#

ACTIVE_=no
UPDATEHASH_=abcdefghijklmnopqrstuvwxyzABCDEFGHIJK1234567
DOMAIN_=mynextcloud.example.com
UPDATEINTERVAL_=30
DESCRIPTION="DDNS FreeDNS client (need account)"

UPDATEURL=https://freedns.afraid.org/dynamic/update.php
URL="${UPDATEURL}?${UPDATEHASH_}"

install()
{
  apt-get update
  apt-get install --no-install-recommends -y dnsutils
}

configure() 
{
  [[ $ACTIVE_ != "yes" ]] && { 
    rm /etc/cron.d/freeDNS
    service cron restart
    echo "FreeDNS client is disabled"
    return 0
  }

  cat > /usr/local/bin/freedns.sh <<EOF
#!/bin/bash
echo "FreeDNS client started"
echo "${URL}"
registeredIP=\$(nslookup ${DOMAIN_}|tail -n2|grep A|sed s/[^0-9.]//g)
currentIP=\$(wget -q -O - http://checkip.dyndns.org|sed s/[^0-9.]//g)
    [ "\$currentIP" != "\$registeredIP" ] && {
        wget -q -O /dev/null ${URL}
  }
echo "Registered IP: \$registeredIP | Current IP: \$currentIP"
EOF
  chmod +744 /usr/local/bin/freedns.sh

  echo "*/${UPDATEINTERVAL_}  *  *  *  *  root  /bin/bash /usr/local/bin/freedns.sh" > /etc/cron.d/freeDNS
  service cron restart

  cd /var/www/nextcloud
  sudo -u www-data php occ config:system:set trusted_domains 3 --value="$DOMAIN_"
  sudo -u www-data php occ config:system:set overwrite.cli.url --value=https://"$DOMAIN_"

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
