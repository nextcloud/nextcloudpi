#!/bin/bash

# Updater for NextCloudPi
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at https://ownyourbits.com/
#

CONFDIR=/usr/local/etc/nextcloudpi-config.d/

# don't make sense in a docker container
EXCL_DOCKER="
nc-automount.sh
nc-format-USB.sh
nc-datadir.sh
nc-database.sh
nc-ramlogs.sh
nc-swapfile.sh
nc-static-IP.sh
nc-wifi.sh
nc-nextcloud.sh
nc-init.sh
"

# need to be fixed for this
EXCL_DOCKER+="
nc-webui.sh
fail2ban.sh
spDYN.sh
"

# better use a designated container
EXCL_DOCKER+="
samba.sh
NFS.sh
"

# use systemd timers
EXCL_DOCKER+="
nc-notify-updates.sh
nc-scan-auto.sh
nc-backup-auto.sh
freeDNS.sh
"

# TODO think about updates
EXCL_DOCKER+="
nc-update.sh
nc-autoupdate-ncp.sh
"

# check running apt
pgrep apt &>/dev/null && { echo "apt is currently running. Try again later";  exit 1; }

cp etc/library.sh /usr/local/etc/

source /usr/local/etc/library.sh

# prevent installing some apt packages in the docker version
[[ "$DOCKERBUILD" == 1 ]] && {
  mkdir -p $CONFDIR
  for opt in $EXCL_DOCKER; do 
    touch $CONFDIR/$opt
done
}

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

# remove unwanted packages for the docker version
[[ "$DOCKERBUILD" == 1 ]] && {
  for opt in $EXCL_DOCKER; do 
    rm $CONFDIR/$opt
done
}

## BACKWARD FIXES ( for older images )

# only for image builds
[[ ! -f /.ncp-image ]] && {

  # log adjustment for wizard
  test -f /home/www/ncp-launcher.sh && \
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
RET=$?

# clean log for the next PHP backend call to start clean,
# but wait until everything from current execution is read
sleep 0.5 && echo "" > /run/ncp.log

exit $RET
EOF

  # 2 days to avoid very big backups requests to timeout
  test -f /etc/apache2/sites-available/ncp.conf && {
    grep -q TimeOut /etc/apache2/sites-available/ncp.conf || \
      sed -i '/SSLCertificateKeyFile/aTimeOut 172800' /etc/apache2/sites-available/ncp.conf
  } || echo "Warning. File /etc/apache2/sites-available/ncp.conf not found on your ncp."

  # relocate noip2 config
  mkdir -p /usr/local/etc/noip2

  # redis
  REDIS_CONF=/etc/redis/redis.conf
  sysctl vm.overcommit_memory=1 &>/dev/null
  grep -q APCu /var/www/nextcloud/config/config.php && {
    echo "installing redis..."
    apt-get update
    apt-get install -y --no-install-recommends redis-server php7.0-redis

    sed -i '/memcache/d' /var/www/nextcloud/config/config.php
    sed -i '$d'          /var/www/nextcloud/config/config.php

    cat >> /var/www/nextcloud/config/config.php <<'EOF'
  'memcache.local' => '\OC\Memcache\Redis',
  'memcache.locking' => '\OC\Memcache\Redis',
  'redis' =>
  array (
    'host' => '/var/run/redis/redis.sock',
    'port' => 0,
    'timeout' => 0.0,
  ),
);
EOF

  REDIS_MEM=3gb
  sed -i "s|# unixsocket .*|unixsocket /var/run/redis/redis.sock|" $REDIS_CONF
  sed -i "s|# unixsocketperm .*|unixsocketperm 770|"               $REDIS_CONF
  sed -i "s|port.*|port 0|"                                        $REDIS_CONF
  echo "maxmemory ${REDIS_MEM}" >> $REDIS_CONF
  echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf

  sudo usermod -a -G redis www-data

  systemctl restart redis-server
  systemctl enable redis-server

  # need to restart php
  bash -c " sleep 3
            systemctl stop php7.0-fpm
            systemctl stop mysqld
            sleep 0.5
            systemctl start php7.0-fpm
            systemctl start mysqld
            " &>/dev/null &
  }
  sed -i 's|^logfile.*|logfile /var/log/redis/redis-server.log|' $REDIS_CONF

  # fix redis update bug
  grep -q sock700 $REDIS_CONF && {
    sed -i '/unixsocket/d' $REDIS_CONF
    echo "unixsocket /var/run/redis/redis.sock" >> $REDIS_CONF
    echo "unixsocketperm 770"                   >> $REDIS_CONF
    systemctl restart redis-server
  }
  grep -q unixsocketperm $REDIS_CONF || echo unixsocketperm 770 >> $REDIS_CONF

# fix unattended
  NUSER=$( grep USER_ /usr/local/etc/nextcloudpi-config.d/nc-notify-updates.sh | head -1 | cut -f2 -d= )
  cat > /usr/local/bin/ncp-notify-unattended-upgrade <<EOF
#!/bin/bash

LOGFILE=/var/log/unattended-upgrades/unattended-upgrades.log
STAMPFILE=/var/run/.ncp-notify-unattended-upgrades
VERFILE=/usr/local/etc/ncp-version

test -e "\$LOGFILE" || { echo "\$LOGFILE not found"; exit 1; }

# find lines with package updates
LINE=\$( grep "INFO Packages that will be upgraded:" "\$LOGFILE" )

[[ "\$LINE" == "" ]] && { echo "no new upgrades"; exit 0; }

# extract package names
PKGS=\$( sed 's|^.*Packages that will be upgraded: ||' <<< "\$LINE" | tr '\\n' ' ' )

# mark lines as read
sed -i 's|INFO Packages that will be upgraded:|INFO Packages that will be upgraded :|' \$LOGFILE

echo -e "Packages automatically upgraded: \$PKGS\\n"

# notify
sudo -u www-data php /var/www/nextcloud/occ notification:generate \
  $NUSER "NextCloudPi Unattended Upgrades" \
     -l "Packages automatically upgraded \$PKGS"
EOF
  chmod +x /usr/local/bin/ncp-notify-unattended-upgrade

  # fix modsecurity uploads
  sed -i 's|^SecRequestBodyLimit .*|#SecRequestBodyLimit 13107200|' /etc/modsecurity/modsecurity.conf

  # fix ramlogs
  [[ $( grep "^ACTIVE_" /usr/local/etc/nextcloudpi-config.d/nc-ramlogs.sh | cut -f2 -d'=' ) == "yes" ]] && {
    mkdir -p /usr/lib/systemd/system
    cat > /usr/lib/systemd/system/ramlogs.service <<'EOF'
[Unit]
Description=Populate ramlogs dir
Requires=network.target
Before=redis-server apache2 mysqld

[Service]
ExecStart=/bin/bash /usr/local/bin/ramlog-dirs.sh

[Install]
WantedBy=multi-user.target
EOF

    cat > /usr/local/bin/ramlog-dirs.sh <<'EOF'
#!/bin/bash
mkdir -p /var/log/myslq
chown mysql /var/log/mysql

mkdir -p /var/log/apache2
chown apache2 /var/log/apache2

mkdir -p /var/log/redis
chown redis /var/log/redis
EOF
    systemctl enable ramlogs
  }

  # fix automount in latest images
   test -f /etc/udev/rules.d/90-qemu.rules && {
     rm -f /etc/udev/rules.d/90-qemu.rules
     udevadm control --reload-rules && udevadm trigger
     pgrep -c udiskie &>/dev/null && systemctl restart nc-automount
   }

   # btrfs tools
   type btrfs &>/dev/null || {
    apt-get update 
    apt-get install -y --no-install-recommends btrfs-tools
  }
}

exit 0

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

