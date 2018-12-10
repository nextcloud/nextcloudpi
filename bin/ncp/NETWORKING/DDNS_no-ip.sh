#!/bin/bash

# no-ip.org installation on Raspbian 
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at https://ownyourbits.com/2017/03/05/dynamic-dns-for-raspbian-with-no-ip-org-installer/
#


install()
{
  apt-get update
  apt-get install --no-install-recommends -y make gcc libc-dev

  local TMPDIR="$( mktemp -d /tmp/noip.XXXXXX )"
  cd "$TMPDIR"
  wget -O- --content-disposition https://github.com/nachoparker/noip-DDNS/archive/master/latest.tar.gz \
  | tar -xz \
  || return 1
  cd -; cd "$OLDPWD"/noip-DDNS-master/
  make
  cp noip2 /usr/local/bin/

  cat > /etc/init.d/noip2 <<'EOF'
#! /bin/sh
# /etc/init.d/noip2

### BEGIN INIT INFO
# Provides:          no-ip.org
# Required-Start:    $local_fs $remote_fs
# Required-Stop:     $local_fs $remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start no-ip.org dynamic DNS
### END INIT INFO
EOF

  cat debian.noip2.sh >> /etc/init.d/noip2 

  chmod +x /etc/init.d/noip2
  cd -
  rm -r "$TMPDIR"

  update-rc.d noip2 defaults
  update-rc.d noip2 disable

  mkdir -p /usr/local/etc/noip2

  [[ "$DOCKERBUILD" == 1 ]] && {
    cat > /etc/services-available.d/100noip <<EOF
#!/bin/bash

source /usr/local/etc/library.sh

[[ "\$1" == "stop" ]] && {
  echo "stopping noip..."
  service noip2 stop
  exit 0
}

persistent_cfg /usr/local/etc/noip2 /data/etc/noip2

echo "Starting noip..."
service noip2 start

exit 0
EOF
    chmod +x /etc/services-available.d/100noip
  }
}

configure() 
{
  service noip2 stop
  [[ $ACTIVE != "yes" ]] && { update-rc.d noip2 disable; return 0; }

  local IF=$( ip -br l | awk '{ if ( $2 == "UP" ) print $1 }' | head -1 )
  [[ "$IF" != "" ]] && IF="-I $IF"

  /usr/local/bin/noip2 -C -c /usr/local/etc/no-ip2.conf $IF -U "$TIME" -u "$USER" -p "$PASS" 2>&1 | tee >(cat - >&2) \
    | grep -q "New configuration file .* created" || return 1

  update-rc.d noip2 enable
  service noip2 restart
  cd /var/www/nextcloud
  sudo -u www-data php occ config:system:set trusted_domains 3 --value="$DOMAIN"
  sudo -u www-data php occ config:system:set overwrite.cli.url --value=https://"$DOMAIN"/
  echo "noip DDNS enabled"

}

cleanup()
{
  # this uninstalls udiskie, commented out
 #  udiskie with these dependencies fixed in Buster
  # apt-get purge -y make gcc libc-dev
  :
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

