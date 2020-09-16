#!/bin/bash

# Namecheap DNS updater client installation on Raspbian 
#
# Copyleft 2020 by ndunks and Huizerd
# GPL licensed (see end of file) * Use at your own risk!
#
# Based on:
# - https://gist.github.com/ndunks/c756030c0757b667c9a478c97ca5a9b7
# - https://www.namecheap.com/support/knowledgebase/article.aspx/29/11/how-do-i-use-a-browser-to-dynamically-update-the-hosts-ip
#
# Further steps to be taken:
# - Buying a Namecheap domain
# - https://www.namecheap.com/support/knowledgebase/article.aspx/595/11/how-do-i-enable-dynamic-dns-for-a-domain/
# - https://www.namecheap.com/support/knowledgebase/article.aspx/43/11/how-do-i-set-up-a-host-for-dynamic-dns


install()
{
  apt-get update
  apt-get install --no-install-recommends -y dnsutils
}

configure() 
{
  local updateurl=https://dynamicdns.park-your-domain.com/update
  local url="${updateurl}?host=${HOST}&domain=${DOMAIN}&password=${PASSWORD}"

  [[ $ACTIVE != "yes" ]] && { 
    rm -f /etc/cron.d/namecheapDNS
    service cron restart
    echo "Namecheap DNS client is disabled"
    return 0
  }

  cat > /usr/local/bin/namecheapdns.sh <<EOF
#!/bin/bash
echo "Namecheap DNS client started"
registeredIP=\$(dig +short "$FULLDOMAIN"|tail -n1)
currentIP=\$(wget -q -O - http://checkip.dyndns.org|sed s/[^0-9.]//g)
echo "${url}&ip=${currentIP}"
    [ "\$currentIP" != "\$registeredIP" ] && {
        wget -q -O /dev/null "${url}&ip=${currentIP}"
  }
echo "Registered IP: \$registeredIP | Current IP: \$currentIP"
EOF
  chmod +744 /usr/local/bin/namecheapdns.sh

  echo "*/${UPDATEINTERVAL}  *  *  *  *  root  /bin/bash /usr/local/bin/namecheapdns.sh" > /etc/cron.d/namecheapDNS
  chmod 644 /etc/cron.d/namecheapDNS
  service cron restart

  cd /var/www/nextcloud
  sudo -u www-data php occ config:system:set trusted_domains 3 --value="$FULLDOMAIN"
  sudo -u www-data php occ config:system:set overwrite.cli.url --value=https://"$FULLDOMAIN"/

  echo "Namecheap DNS client is enabled"
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
