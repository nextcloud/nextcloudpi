#!/bin/bash

# OVH DynHost updater client installation on Raspbian 
#
# Copyleft 2022 by Aeris1One
# GPL licensed (see end of file) * Use at your own risk!
#
# Based on:
# - previous work on Namecheap DNS by ndunks and Huizerd
# - https://github.com/zwindler/dynhost
#
# Further steps to be taken:
# - Buying an OVH domain
# - https://docs.ovh.com/gb/en/domains/hosting_dynhost/


install()
{
  apt-get update
  apt-get install --no-install-recommends -y dnsutils
}

configure() 
{
  local updateurl=https://www.ovh.com/nic/update?system=dyndns
  local url="${updateurl}?system=dyndns&hostname=${HOSTNAME}"

  [[ $ACTIVE != "yes" ]] && { 
    rm -f /etc/cron.d/ovhDNS
    systemctl restart cron
    echo "OVH DNS client is disabled"
    return 0
  }

  cat > /usr/local/bin/ovhdns.sh <<EOF
#!/bin/bash
echo "OVH DNS client started"
registeredIP=\$(dig +short "$HOSTNAME"|tail -n1)
currentIP=\$(wget -q -O - http://checkip.dyndns.org|sed s/[^0-9.]//g)
echo "${url}&ip=${currentIP}"
    [ "\$currentIP" != "\$registeredIP" ] && {
        wget --user="${USER}" --password="${PASSWORD}" -q -O /dev/null "${url}&ip=${currentIP}"
  }
echo "Registered IP: \$registeredIP | Current IP: \$currentIP"
EOF
  chmod +744 /usr/local/bin/ovhdns.sh

  echo "*/${UPDATEINTERVAL}  *  *  *  *  root  /bin/bash /usr/local/bin/ovhdns.sh" > /etc/cron.d/ovhDNS
  chmod 644 /etc/cron.d/ovhDNS
  systemctl restart cron

  cd /var/www/nextcloud
  sudo -u www-data php occ config:system:set trusted_domains 3 --value="$HOSTNAME"
  sudo -u www-data php occ config:system:set overwrite.cli.url --value=https://"$HOSTNAME"/

  echo "OVH DNS client is enabled"
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
