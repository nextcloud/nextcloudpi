#!/bin/bash

# Updater for NextCloudPi
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at https://ownyourbits.com/
#

CONFDIR=/usr/local/etc/ncp-config.d/

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
nc-hdd-monitor.sh
SSH.sh
fail2ban.sh
NFS.sh
"

# better use a designated container
EXCL_DOCKER+="
samba.sh
"

# check running apt
pgrep apt &>/dev/null && { echo "apt is currently running. Try again later";  exit 1; }

cp etc/library.sh /usr/local/etc/

source /usr/local/etc/library.sh

mkdir -p "$CONFDIR"

# prevent installing some apt packages in the docker version
[[ -f /.docker-image ]] && {
  for opt in $EXCL_DOCKER; do 
    touch $CONFDIR/$opt
done
}

# copy all files in bin and etc
for file in bin/* etc/*; do
  [ -f "$file" ] || continue;
  cp "$file" /usr/local/"$file"
done

# install new entries of ncp-config and update others
for file in etc/ncp-config.d/*; do
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
cp -rT etc/ncp-config.d/l10n "$CONFDIR"/l10n

# these files can contain sensitive information, such as passwords
chown -R root:www-data "$CONFDIR"
chmod 660 "$CONFDIR"/*
chmod 750 "$CONFDIR"/l10n

# install web interface
cp -r ncp-web /var/www/
chown -R www-data:www-data /var/www/ncp-web
chmod 770                  /var/www/ncp-web

[[ -f /.docker-image ]] && {
  # remove unwanted packages for the docker version
  for opt in $EXCL_DOCKER; do rm $CONFDIR/$opt; done

  # update services
  cp docker-common/{lamp/010lamp,nextcloud/020nextcloud,nextcloudpi/000ncp} /etc/services-enabled.d

}

## BACKWARD FIXES ( for older images )

# not for image builds, only live updates
[[ ! -f /.ncp-image ]] && {

  # docker images only
  [[ -f /.docker-image ]] && {
    [[ -e /data/etc/live ]] && {
     cat > /etc/services-available.d/000ncp <<EOF
#!/bin/bash

source /usr/local/etc/library.sh

# INIT NCP CONFIG (first run)
persistent_cfg /usr/local/etc/ncp-config.d /data/ncp
persistent_cfg /usr/local/bin /data/bin
persistent_cfg /etc/services-enabled.d
persistent_cfg /etc/letsencrypt                    # persist SSL certificates
persistent_cfg /etc/shadow                         # persist ncp-web password
persistent_cfg /etc/cron.d
persistent_cfg /etc/cron.daily
persistent_cfg /etc/cron.hourly
persistent_cfg /etc/cron.weekly

exit 0
EOF
      sed -i 's|exit 1|exit 0|' /usr/local/sbin/update-rc.d
    }
  }

  # for non docker images
  [[ ! -f /.docker-image ]] && {
    :
  }

  # Reinstall DDNS_spDYN for use of IPv6 
  rm -r /usr/local/etc/spdnsupdater
  cd /usr/local/etc/ncp-config.d
  install_script DDNS_spDYN.sh

  # update nc-restore
  cd "$CONFDIR" &>/dev/null
  install_script nc-backup.sh
  install_script nc-restore.sh
  cd -          &>/dev/null

  # update to NC14.0.3
  F="$CONFDIR"/nc-autoupdate-nc.sh
  grep -q '^ACTIVE_=yes$' "$F" && {
    cd "$CONFDIR" &>/dev/null
    activate_script nc-autoupdate-nc.sh
    cd -          &>/dev/null
  }

      # Redis eviction policy
      grep -q "^maxmemory-policy allkeys-lru" /etc/redis/redis.conf || {
        sed -i 's|# maxmemory-policy .*|maxmemory-policy allkeys-lru|' /etc/redis/redis.conf
        service redis-server restart
      }

      # allow .lan domains
      ncc config:system:set trusted_domains 7 --value="nextcloudpi"
      ncc config:system:set trusted_domains 8 --value="nextcloudpi.lan"

      # possible traces of the old name
      sed -i 's|NextCloudPlus|NextCloudPi|' /usr/local/bin/ncp-notify-update
      sed -i 's|NextCloudPlus|NextCloudPi|' /usr/local/bin/ncp-notify-unattended-upgrade

      # nc-prettyURL: fix for NC14
      URL="$(ncc config:system:get overwrite.cli.url)"
      [[ "${URL: -1}" != "/" ]] && ncc config:system:set overwrite.cli.url --value="${URL}/"

      # Implement logrotate restrictions
      [[ -f /etc/rsyslog.d/20-ufw.conf ]] && { grep -q "^\& stop" /etc/rsyslog.d/20-ufw.conf ||  echo "& stop" >> /etc/rsyslog.d/20-ufw.conf; }
      [[ -f /etc/logrotate.d/ufw ]] && { grep -q maxsize /etc/logrotate.d/ufw     || sed -i /weekly/amaxsize2M /etc/logrotate.d/ufw; }
      grep -q maxsize /etc/logrotate.d/apache2 || sed -i /weekly/amaxsize2M /etc/logrotate.d/apache2
      service rsyslog restart &>/dev/null
      cat > /etc/logrotate.d/ncp <<'EOF'
/var/log/ncp.log
{
        rotate 4
        size 500K
        missingok
        notifempty
        compress
}
EOF

  # remove redundant opcache configuration. Leave until update bug is fixed -> https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=815968
  # Bug #416 reappeared after we moved to php7.2 and debian buster packages.
  [[ "$( ls -l /etc/php/7.2/fpm/conf.d/*-opcache.ini |  wc -l )" -gt 1 ]] && rm "$( ls /etc/php/7.2/fpm/conf.d/*-opcache.ini | tail -1 )"
  [[ "$( ls -l /etc/php/7.2/cli/conf.d/*-opcache.ini |  wc -l )" -gt 1 ]] && rm "$( ls /etc/php/7.2/cli/conf.d/*-opcache.ini | tail -1 )"

  # update launcher
  cat > /home/www/ncp-launcher.sh <<'EOF'
#!/bin/bash
DIR=/usr/local/etc/ncp-config.d
[[ -f $DIR/$1  ]] || { echo "File not found"; exit 1; }
[[ "$1" =~ ../ ]] && { echo "Forbidden path"; exit 2; }
source /usr/local/etc/library.sh
cd $DIR
launch_script $1
EOF
  chmod 700 /home/www/ncp-launcher.sh

  # Adjust sources
  apt-get update
  apt-get install -y --no-install-recommends apt-transport-https gnupg
  echo "deb https://packages.sury.org/php/ stretch main" > /etc/apt/sources.list.d/php.list
  wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add -
  rm -f /etc/apt/sources.list.d/ncp-buster.list
  rm -f /etc/apt/preferences.d/10-ncp-buster
  apt-get update

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

