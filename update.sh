#!/bin/bash

# Updaterfor  NextCloudPi
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at https://ownyourbits.com/
#

cp etc/library.sh /usr/local/etc/

source /usr/local/etc/library.sh

# fix automount, reinstall if its old version
AMFILE=/usr/local/etc/nextcloudpi-config.d/nc-automount.sh
grep -q nc-automount.service $AMFILE || rm $AMFILE

# copy all files in bin and etc
for file in bin/* etc/*; do
  [ -f "$file" ] || continue;
  cp "$file" /usr/local/"$file"
done

# install new entries of nextcloudpi-config and update others
for file in etc/nextcloudpi-config.d/*; do
  [ -f "$file" ] || continue;    # skip dirs
  [ -f /usr/local/"$file" ] || { # new entry
    install_script "$file"       # install

    # configure if active by default
    grep -q '^ACTIVE_=yes$' "$file" && activate_script "$file" 
  }

  # save current configuration to (possibly) updated script
  [ -f /usr/local/"$file" ] && {
    VARS=( $( grep "^[[:alpha:]]\+_=" /usr/local/"$file" | cut -d= -f1 ) )
    VALS=( $( grep "^[[:alpha:]]\+_=" /usr/local/"$file" | cut -d= -f2 ) )
    for i in $( seq 0 1 ${#VARS[@]} ); do
      sed -i "s|^${VARS[$i]}=.*|${VARS[$i]}=${VALS[$i]}|" "$file"
    done
  }

  cp "$file" /usr/local/"$file"
done

# these files can contain sensitive information, such as passwords
chown -R root:www-data /usr/local/etc/nextcloudpi-config.d
chmod 660 /usr/local/etc/nextcloudpi-config.d/*

# install web interface
cp -r ncp-web /var/www/
chown -R www-data:www-data /var/www/ncp-web
chmod 770                  /var/www/ncp-web

## BACKWARD FIXES ( for older images )

# force-fix unattended-upgrades 
cd /usr/local/etc/nextcloudpi-config.d/ || exit 1
activate_script unattended-upgrades.sh

# for old image users, save default password
test -f /root/.my.cnf || echo -e "[client]\npassword=ownyourbits" > /root/.my.cnf

# fix updates from NC12 to NC12.0.1
chown www-data /var/www/nextcloud/.htaccess
rm -rf /var/www/nextcloud/.well-known

# fix ncp-notify-update
cat > /usr/local/bin/ncp-notify-update <<'EOF'
#!/bin/bash
VERFILE=/usr/local/etc/ncp-version
LATEST=/var/run/.ncp-latest-version
NOTIFIED=/var/run/.ncp-version-notified

test -e $LATEST  || exit 0;
ncp-test-updates || { echo "NextCloudPi up to date"; exit 0; }

test -e $NOTIFIED && [[ "$( cat $LATEST )" == "$( cat $NOTIFIED )" ]] && { 
  echo "Found update from $( cat $VERFILE ) to $( cat $LATEST ). Already notified" 
  exit 0
}

echo "Found update from $( cat $VERFILE ) to $( cat $LATEST ). Sending notification..."

IFACE=$( ip r | grep "default via" | awk '{ print $5 }' )
IP=$( ip a | grep "global $IFACE" | grep -oP '\d{1,3}(.\d{1,3}){3}' | head -1 )

sudo -u www-data php /var/www/nextcloud/occ notification:generate \
  admin "NextCloudPi $( cat $VERFILE )" \
     -l "NextCloudPi $( cat $LATEST ) is available. Update from https://$IP:4443"

cat $LATEST > $NOTIFIED
EOF
  chmod +x /usr/local/bin/ncp-notify-update

# fix permissions for ncp-web: shutdown button
sed -i 's|www-data.*|www-data ALL = NOPASSWD: /home/www/ncp-launcher.sh , /sbin/halt|' /etc/sudoers

# fix fail2ban misconfig in stretch
rm -f /etc/fail2ban/jail.d/defaults-debian.conf

# update ncp-launcher to support realtime updates with SSE
  cat > /home/www/ncp-launcher.sh <<'EOF'
#!/bin/bash
DIR=/usr/local/etc/nextcloudpi-config.d
test -f $DIR/$1 || { echo "File not found"; exit 1; }
source /usr/local/etc/library.sh
cd $DIR
touch /run/ncp.log
chmod 640 /run/ncp.log
chown root:www-data /run/ncp.log
launch_script $1 &> /run/ncp.log
EOF
  chmod 700 /home/www/ncp-launcher.sh

  # adjust max PHP processes so Apps don't overload the board (#146)
  sed -i 's|pm.max_children =.*|pm.max_children = 3|' /etc/php/7.0/fpm/pool.d/www.conf

  # restart PHP
  sleep 3
  systemctl stop php7.0-fpm
  systemctl stop mysqld
  sleep 0.5
  systemctl start php7.0-fpm
  systemctl start mysqld

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

