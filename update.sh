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
cp -rT etc/nextcloudpi-config.d/l10n "$CONFDIR"/l10n

# these files can contain sensitive information, such as passwords
chown -R root:www-data "$CONFDIR"
chmod 660 "$CONFDIR"/*

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
  cd "$CONFDIR" &>/dev/null
  install_script nc-backup.sh &>/dev/null
  cd - &>/dev/null

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
  grep -q '^ACTIVE_=yes$' "$CONFDIR"/samba.sh || update-rc.d nmbd disable

  # fix automount dependencies with other ncp-apps
  sed -i \
    's|^Before=.*|Before=mysqld.service dphys-swapfile.service fail2ban.service smbd.service nfs-server.service|' \
    /usr/lib/systemd/system/nc-automount.service

  sed -i \
    's|^Before=.*|Before=nc-automount.service|' \
    /usr/lib/systemd/system/nc-automount-links.service

  # adjust when other services start
  DBUNIT=/lib/systemd/system/mariadb.service
  F2BUNIT=/lib/systemd/system/fail2ban.service
  SWPUNIT=/etc/init.d/dphys-swapfile 
  grep -q sleep "$DBUNIT"  || sed -i "/^ExecStart=/iExecStartPre=/bin/sleep 10" "$DBUNIT"
  grep -q sleep "$F2BUNIT" || sed -i "/^ExecStart=/iExecStartPre=/bin/sleep 10" "$F2BUNIT"
  grep -q sleep "$SWPUNIT" || sed -i "/\<start)/asleep 30" "$SWPUNIT"

  # disable ncp user login
  chsh -s /usr/sbin/nologin ncp

  # remove old instance of ramlogs
  [[ -f  /usr/lib/systemd/system/ramlogs.service ]] && {
    systemctl disable ramlogs
    rm -f /usr/lib/systemd/system/ramlogs.service /usr/local/bin/ramlog-dirs.sh
  }
  sed -i '/tmpfs \/var\/log.* in RAM$/d' /etc/fstab
  sed -i '/tmpfs \/tmp.* in RAM$/d'      /etc/fstab

  # update ramlogs with log2ram
  type log2ram &>/dev/null || {
    cd "$CONFDIR" &>/dev/null
    install_script nc-ramlogs.sh           &>/dev/null
    grep -q '^ACTIVE_=yes$' "$CONFDIR"/nc-ramlogs.sh && \
      systemctl enable log2ram
    cd -                                   &>/dev/null
  }

  # update nc-backup-auto to use cron
  [[ -f  /etc/systemd/system/nc-backup.timer ]] && {
    systemctl stop    nc-backup.timer
    systemctl disable nc-backup.timer
    rm -f /etc/systemd/system/nc-backup.timer /etc/systemd/system/nc-backup.service
    cd "$CONFDIR" &>/dev/null
    grep -q '^ACTIVE_=yes$' "$CONFDIR"/nc-backup-auto.sh && \
      activate_script nc-backup-auto.sh
    cd -          &>/dev/null
  }

  # make sure the redis directory exists
  mkdir -p /var/log/redis
  chown redis /var/log/redis

  # improve dependency of database with automount
  sed -i 's|^ExecStartPre=/bin/sleep .*|ExecStartPre=/bin/sleep 20|' /lib/systemd/system/mariadb.service
  sed -i 's|^Restart=.*|Restart=on-failure|'                         /lib/systemd/system/mariadb.service

  # fix for nc-automount-links
  cat > /usr/local/etc/nc-automount-links <<'EOF'
#!/bin/bash

ls -d /media/* &>/dev/null && {

  # remove old links
  for l in $( ls /media/ ); do
    test -L /media/"$l" && rm /media/"$l"
  done

  # create links
  i=0
  for d in $( ls -d /media/* 2>/dev/null ); do
    if [ $i -eq 0 ]; then
      test -e /media/USBdrive   || test -d "$d" && ln -sT "$d" /media/USBdrive
    else
      test -e /media/USBdrive$i || test -d "$d" && ln -sT "$d" /media/USBdrive$i
    fi
    i=$(( i + 1 ))
  done

}
EOF
  chmod +x /usr/local/etc/nc-automount-links

  # fix updates from NC12 to NC12.0.1
  rm -rf /var/www/nextcloud/.well-known

  # remove .well-known after each renewal
  test -d /etc/letsencrypt/live && {
    cat > /etc/cron.weekly/letsencrypt-ncp <<EOF
#!/bin/bash
/etc/letsencrypt/certbot-auto renew --quiet
rm -rf /var/www/nextcloud/.well-known
EOF
    chmod +x /etc/cron.weekly/letsencrypt-ncp
  }

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

