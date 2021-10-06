#!/bin/bash

# dnsmasq DNS server with cache installation on Raspbian
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at: https://ownyourbits.com/2017/03/09/dnsmasq-as-dns-cache-server-for-nextcloudpi-and-raspbian/
#


install()
{
  apt-get update
  apt-get install --no-install-recommends -y dnsmasq
  update-rc.d dnsmasq disable

  [[ "$DOCKERBUILD" == 1 ]] && {
    cat > /etc/services-available.d/100dnsmasq <<EOF
#!/bin/bash

source /usr/local/etc/library.sh

[[ "\$1" == "stop" ]] && {
  echo "stopping dnsmasq..."
  service dnsmasq stop
  exit 0
}

persistent_cfg /etc/dnsmasq.conf

echo "Starting dnsmasq..."
service dnsmasq start

exit 0
EOF
    chmod +x /etc/services-available.d/100dnsmasq
  }
  return 0
}

configure()
{
  [[ $ACTIVE != "yes" ]] && {
    service dnsmasq stop
    update-rc.d dnsmasq disable
    echo "dnmasq disabled"
    return
  }

  local IFACE IP
  IFACE=$( ip r | grep "default via"   | awk '{ print $5 }' | head -1 )
  IP=$( ncc config:system:get trusted_domains "${TRUSTED_DOMAINS[docker_overwrite]}" | grep -oP '\d{1,3}(.\d{1,3}){3}' )
  [[ "$IP" == "" ]] && IP="$(get_ip)"

  [[ "$IP" == "" ]] && { echo "could not detect IP"; return 1; }

  cat > /etc/dnsmasq.conf <<EOF
interface=$IFACE
domain-needed         # Never forward plain names (without a dot or domain part)
bogus-priv            # Never forward addresses in the non-routed address spaces.
no-poll               # Don't poll for changes in /etc/resolv.conf
no-resolv             # Don't use /etc/resolv.conf or any other file
cache-size=$CACHESIZE
server=$DNSSERVER
address=/$DOMAIN/$IP  # This is optional if we add it to /etc/hosts
EOF

  # required to run in container
  test -d /data && echo "user=root" >> /etc/dnsmasq.conf

  sed -i 's|#\?IGNORE_RESOLVCONF=.*|IGNORE_RESOLVCONF=yes|' /etc/default/dnsmasq

  update-rc.d dnsmasq defaults
  update-rc.d dnsmasq enable
  service dnsmasq restart
  ncc config:system:set trusted_domains "${TRUSTED_DOMAINS[dnsmasq]}" --value="$DOMAIN"
  set-nc-domain "$DOMAIN" --no-trusted-domain
  echo "dnsmasq enabled"
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

