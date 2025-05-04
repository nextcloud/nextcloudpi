#!/bin/bash

# DynuDNS updater client installation on Raspbian
#
# Copyleft 2022 by Stefano Guandalini <guandalf _a_t_ protonmail _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#



install()
{
  apt-get update
  apt-get install --no-install-recommends -y dnsutils
}

configure() 
{
  local updateurl=https://api.dynu.com/nic/update
  local url="${updateurl}?hostname=${DOMAIN}&myipv6=${MYIPV6}&password=${PASSWORD}"

  [[ $ACTIVE != "yes" ]] && { 
    rm -f /etc/cron.d/dynuDNS
    service cron restart
    echo "dynuDNS client is disabled"
    return 0
  }

  cat > /usr/local/bin/dynudns.sh <<EOF
#!/bin/bash
echo "DynuDNS client started"
echo "${url}"
registeredIP=\$(dig +short "$DOMAIN"|tail -n1)
currentIP=\$(wget -q -O - http://checkip.dyndns.org|sed s/[^0-9.]//g)
    [ "\$currentIP" != "\$registeredIP" ] && {
        wget -q -O /dev/null "${url}"
  }
echo "Registered IP: \$registeredIP | Current IP: \$currentIP"
EOF
  chmod +744 /usr/local/bin/dynudns.sh

  echo "*/${UPDATEINTERVAL}  *  *  *  *  root  /bin/bash /usr/local/bin/dynudns.sh" > /etc/cron.d/dynuDNS
  chmod 644 /etc/cron.d/dynuDNS
  service cron restart

  set-nc-domain "$DOMAIN"

  echo "DynuDNS client is enabled"
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
