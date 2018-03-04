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
UFW.sh
nc-snapshot.sh
nc-snapshot-auto.sh
nc-audit.sh
SSH.sh
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

# install localization files
cp -rT etc/nextcloudpi-config.d/l10n /usr/local/etc/nextcloudpi-config.d/l10n

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

# not for image builds, only live updates
[[ ! -f /.ncp-image ]] && {

  # update ncp-backup
  cd /usr/local/etc/nextcloudpi-config.d &>/dev/null
  install_script nc-backup.sh
  cd - &>/dev/null

  # update ncp-backup-auto
  cd /usr/local/etc/nextcloudpi-config.d &>/dev/null
  install_script nc-backup-auto.sh
  cd - &>/dev/null

  # refresh nc-backup-auto
  cd /usr/local/etc/nextcloudpi-config.d &>/dev/null
  grep -q '^ACTIVE_=yes$' nc-backup-auto.sh && activate_script nc-backup-auto.sh 
  cd - &>/dev/null

  # add ncp-config link
  [[ -e /usr/local/bin/ncp-config ]] || ln -s /usr/local/bin/nextcloudpi-config /usr/local/bin/ncp-config

  # turn modsecurity logs off, too spammy
  sed -i 's|SecAuditEngine .*|SecAuditEngine Off|' /etc/modsecurity/modsecurity.conf

  # fix unattended upgrades failing on modified files
  grep -q Dpkg::Options /etc/apt/apt.conf.d/20nextcloudpi-upgrades || \
    cat >> /etc/apt/apt.conf.d/20nextcloudpi-upgrades <<EOF
Dpkg::Options {
   "--force-confdef";
   "--force-confold";
};
EOF

  # some added security
  sed -i 's|^ServerSignature .*|ServerSignature Off|' /etc/apache2/conf-enabled/security.conf
  sed -i 's|^ServerTokens .*|ServerTokens Prod|'      /etc/apache2/conf-enabled/security.conf

  # remove redundant configuration from unattended upgrades
  [[ "$( ls -l /etc/php/7.0/fpm/conf.d/*-opcache.ini |  wc -l )" -gt 1 ]] && rm "$( ls /etc/php/7.0/fpm/conf.d/*-opcache.ini | tail -1 )"
  [[ "$( ls -l /etc/php/7.0/cli/conf.d/*-opcache.ini |  wc -l )" -gt 1 ]] && rm "$( ls /etc/php/7.0/cli/conf.d/*-opcache.ini | tail -1 )"

  # upgrade launcher after logging improvements
  cat > /home/www/ncp-launcher.sh <<'EOF'
#!/bin/bash
DIR=/usr/local/etc/nextcloudpi-config.d
test -f $DIR/$1 || { echo "File not found"; exit 1; }
source /usr/local/etc/library.sh
cd $DIR
launch_script $1
EOF
  chmod 700 /home/www/ncp-launcher.sh

  # update sudoers permissions for the reboot command
  grep -q reboot /etc/sudoers || \
    sed -i 's|www-data.*|www-data ALL = NOPASSWD: /home/www/ncp-launcher.sh , /sbin/halt, /sbin/reboot|' /etc/sudoers

  # randomize passwords for old images ( older than v0.46.30 )
  cat > /usr/lib/systemd/system/nc-provisioning.service <<'EOF'
[Unit]
Description=Randomize passwords on first boot
Requires=network.target
After=mysql.service

[Service]
ExecStart=/bin/bash /usr/local/bin/ncp-provisioning.sh

[Install]
WantedBy=multi-user.target
EOF

  systemctl enable nc-provisioning

  NEED_UPDATE=false

  MAJOR=0 MINOR=46 PATCH=30

  MAJ=$( grep -oP "\d+\.\d+\.\d+" /usr/local/etc/ncp-version | cut -d. -f1 )
  MIN=$( grep -oP "\d+\.\d+\.\d+" /usr/local/etc/ncp-version | cut -d. -f2 )
  PAT=$( grep -oP "\d+\.\d+\.\d+" /usr/local/etc/ncp-version | cut -d. -f3 )

  if [ "$MAJOR" -gt "$MAJ" ]; then
    NEED_UPDATE=true
  elif [ "$MAJOR" -eq "$MAJ" ] && [ "$MINOR" -gt "$MIN" ]; then
    NEED_UPDATE=true
  elif [ "$MAJOR" -eq "$MAJ" ] && [ "$MINOR" -eq "$MIN" ] && [ "$PATCH" -gt "$PAT" ]; then
    NEED_UPDATE=true
  fi

  [[ "$NEED_UPDATE" == "true" ]] && {
    REDISPASS="default"
    DBPASSWD="default"
    sed -i -E "s|^requirepass .*|requirepass $REDISPASS|" /etc/redis/redis.conf
    echo -e "[client]\npassword=$DBPASSWD" > /root/.my.cnf
    chmod 600 /root/.my.cnf
    systemctl start nc-provisioning
  }

  # adjust services
  systemctl mask nfs-blkmap
  grep -q '^ACTIVE_=yes$' /usr/local/etc/nextcloudpi-config.d/samba.sh || \
    update-rc.d nmbd disable

  # fix automount dependencies with other ncp-apps
  sed -i \
    's|^Before=.*|Before=mysqld.service dphys-swapfile.service fail2ban.service smbd.service nfs-server.service|' \
    /usr/lib/systemd/system/nc-automount.service

  sed -i \
    's|^Before=.*|Before=nc-automount.service|' \
    /usr/lib/systemd/system/nc-automount-links.service

  # fix ramlogs dependencies with other ncp-apps
  sed -i \
    's|^Before=.*|Before=redis-server.service apache2.service mysqld.service|' \
    /usr/lib/systemd/system/ramlogs.service

  # adjust when other services start
  DBUNIT=/lib/systemd/system/mariadb.service
  F2BUNIT=/lib/systemd/system/fail2ban.service
  SWPUNIT=/etc/init.d/dphys-swapfile 
  grep -q sleep "$DBUNIT"  || sed -i "/^ExecStart=/iExecStartPre=/bin/sleep 10" "$DBUNIT"
  grep -q sleep "$F2BUNIT" || sed -i "/^ExecStart=/iExecStartPre=/bin/sleep 10" "$F2BUNIT"
  grep -q sleep "$SWPUNIT" || sed -i "/\<start)/asleep 30" "$SWPUNIT"

  # disable ncp user login
  chsh -s /usr/sbin/nologin ncp

} # end - only live updates

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

