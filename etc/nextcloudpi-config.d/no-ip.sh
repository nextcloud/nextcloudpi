#!/bin/bash

# no-ip.org installation on Raspbian 
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh no-ip.sh <IP> (<img>)
#
# See installer.sh instructions for details
#
# More at https://ownyourbits.com/2017/03/05/dynamic-dns-for-raspbian-with-no-ip-org-installer/
#

ACTIVE_=no
USER_=my-noip-user@email.com
PASS_=noip-pass
DOMAIN_=mycloud.ownyourbits.com
TIME_=30
DESCRIPTION="DDNS no-ip free provider (need account)"

INFO="For this step to succeed, you need to register a noip account first.
Internet access is required for this configuration to complete."

install()
{
  apt-get update
  apt-get install --no-install-recommends -y make 
  mkdir /tmp/noip && cd /tmp/noip
  wget http://www.no-ip.com/client/linux/noip-duc-linux.tar.gz
  tar vzxf noip-duc-linux.tar.gz
  cd -; cd "$OLDPWD"/noip-2*
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
  rm -r /tmp/noip

  update-rc.d noip2 defaults
  update-rc.d noip2 disable

  mkdir -p /usr/local/etc/noip2

  [[ "$DOCKERBUILD" == 1 ]] && {
    cat > /etc/services.d/100-noip-run.sh <<EOF
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
    chmod +x /etc/services.d/100-noip-run.sh
  }
}

configure() 
{
  service noip2 stop
  [[ $ACTIVE_ != "yes" ]] && { update-rc.d noip2 disable; return 0; }

  ping  -W 2 -w 1 -q github.com &>/dev/null || { echo "No internet connectivity"; return 1; echo "noip DDNS disabled"; }

  /usr/local/bin/noip2 -C -c /usr/local/etc/no-ip2.conf -U "$TIME_" -u "$USER_" -p "$PASS_" || return 1
  update-rc.d noip2 enable
  service noip2 restart
  cd /var/www/nextcloud
  sudo -u www-data php occ config:system:set trusted_domains 3 --value="$DOMAIN_"
  sudo -u www-data php occ config:system:set overwrite.cli.url --value=https://"$DOMAIN_"
  echo "noip DDNS enabled"

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

