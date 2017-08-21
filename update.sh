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

# copy all files in bin and etc
for file in bin/* etc/*; do
  [ -f $file ] || continue;
  cp $file /usr/local/$file
done

# install new entries of nextcloudpi-config and update others
for file in etc/nextcloudpi-config.d/*; do
  [ -f $file ] || continue;    # skip dirs
  [ -f /usr/local/$file ] || { # new entry
    install_script $file       # install

    # configure if active by default
    grep -q '^ACTIVE_=yes$' $file && activate_script $file 
  }

  # save current configuration to (possibly) updated script
  [ -f /usr/local/$file ] && {
    VARS=( $( grep "^[[:alpha:]]\+_=" /usr/local/$file | cut -d= -f1 ) )
    VALS=( $( grep "^[[:alpha:]]\+_=" /usr/local/$file | cut -d= -f2 ) )
    for i in `seq 0 1 ${#VARS[@]} `; do
      sed -i "s|^${VARS[$i]}=.*|${VARS[$i]}=${VALS[$i]}|" $file
    done
  }

  cp $file /usr/local/$file
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
cd /usr/local/etc/nextcloudpi-config.d/
activate_script unattended-upgrades.sh

# for old image users, save default password
test -f /root/.my.cnf || echo -e "[client]\npassword=ownyourbits" > /root/.my.cnf

# fix updates from NC12 to NC12.0.1
chown www-data /var/www/nextcloud/.htaccess
rm -rf /var/www/nextcloud/.well-known

# fix automount
cat > /usr/local/etc/blknum <<'EOF'
#!/bin/bash

# we perform a cleanup with the first one
ls -d /dev/USBdrive* &>/dev/null || {
  rmdir /media/USBdrive*
  for f in `ls /media/`; do
    test -L $f && rm $f
  done
  exit 0
}

for i in `seq 1 1 8`; do
  test -e /media/USBdrive$i && continue
  echo $i
  exit 0
done

exit 1
EOF
  chmod +x /usr/local/etc/blknum

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

