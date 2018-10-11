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

# rename DDNS entries TODO temporary
[[ -f "$CONFDIR"/no-ip.sh ]] && {
  mv "$CONFDIR"/no-ip.sh   "$CONFDIR"/DDNS_no-ip.sh
  mv "$CONFDIR"/freeDNS.sh "$CONFDIR"/DDNS_freeDNS.sh
  mv "$CONFDIR"/duckDNS.sh "$CONFDIR"/DDNS_duckDNS.sh
  mv "$CONFDIR"/spDYN.sh   "$CONFDIR"/DDNS_spDYN.sh
}

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
  cp docker-common/{lamp/010lamp,nextcloud/020nextcloud,nextcloudpi/000ncp} /etc/services-available.d

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
persistent_cfg /etc/services-enabled.d
persistent_cfg /etc/letsencrypt                    # persist SSL certificates
persistent_cfg /etc/shadow                         # persist ncp-web password
persistent_cfg /etc/cron.d
persistent_cfg /etc/cron.daily
persistent_cfg /etc/cron.hourly
persistent_cfg /etc/cron.weekly

exit 0
EOF
      /etc/services-available.d/000ncp
      rm /data/etc/letsencrypt/live
      mv /data/etc/live /data/etc/letsencrypt

      sed -i 's|exit 1|exit 0|' /usr/local/sbin/update-rc.d
    }
  }

  # for non docker images
  [[ ! -f /.docker-image ]] && {
    # fix locale for Armbian images, for ncp-config
    [[ "$LANG" == "" ]] && localectl set-locale LANG=en_US.utf8
  }

  # no-origin policy for enhanced privacy
  grep -q "Referrer-Policy" /etc/apache2/apache2.conf || {
    cat >> /etc/apache2/apache2.conf <<EOF
<IfModule mod_headers.c>
  Header always set Referrer-Policy "no-referrer"
</IfModule>
EOF
  }

  # NC14 doesnt support php mail
  mail_smtpmode=$(sudo -u www-data php /var/www/nextcloud/occ config:system:get mail_smtpmode)
  [[ $mail_smtpmode == "php" ]] && {
    sudo -u www-data php /var/www/nextcloud/occ config:system:set mail_smtpmode --value="sendmail"
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

  # install preview generator
  sudo -u www-data php /var/www/nextcloud/occ app:install previewgenerator
  sudo -u www-data php /var/www/nextcloud/occ app:enable  previewgenerator

  # use separate db config file
  [[ -f /etc/mysql/mariadb.conf.d/90-ncp.cnf ]] || {
    cp /etc/mysql/mariadb.conf.d/50-server.cnf /etc/mysql/mariadb.conf.d/90-ncp.cnf
    service mysql restart
  }

  # update to NC14.0.2
  F="$CONFDIR"/nc-autoupdate-nc.sh
  grep -q '^ACTIVE_=yes$' "$F" && {
    cd "$CONFDIR" &>/dev/null
    activate_script nc-autoupdate-nc.sh
    cd -          &>/dev/null
  }

  # PHP7.2
  [[ -e /etc/php/7.2 ]] || {
    PHPVER=7.2
    APTINSTALL="apt-get install -y --no-install-recommends"
    export DEBIAN_FRONTEND=noninteractive

    ncc maintenance:mode --on

    [[ -f /usr/bin/raspi-config ]] && {
      apt-get update
      $APTINSTALL apt-transport-https

      echo "deb https://deb.debian.org/debian buster main contrib non-free" > /etc/apt/sources.list.d/ncp-buster.list
      apt-get     --allow-unauthenticated update
      $APTINSTALL --allow-unauthenticated debian-archive-keyring
    }

    echo "deb http://deb.debian.org/debian buster main contrib non-free" > /etc/apt/sources.list.d/ncp-buster.list
cat > /etc/apt/preferences.d/10-ncp-buster <<EOF
Package: *
Pin: release n=stretch
Pin-Priority: 600
EOF
    apt-get update

    apt-get purge -y php7.0-*
    apt-get autoremove -y

    $APTINSTALL -t buster php${PHPVER} php${PHPVER}-curl php${PHPVER}-gd php${PHPVER}-fpm php${PHPVER}-cli php${PHPVER}-opcache \
                          php${PHPVER}-mbstring php${PHPVER}-xml php${PHPVER}-zip php${PHPVER}-fileinfo php${PHPVER}-ldap \
                          php${PHPVER}-intl php${PHPVER}-bz2 php${PHPVER}-json
 
      $APTINSTALL php${PHPVER}-mysql
      $APTINSTALL -t buster php${PHPVER}-redis
      $APTINSTALL -t buster php-smbclient                                         # for external storage
      $APTINSTALL -t buster imagemagick php${PHPVER}-imagick php${PHPVER}-exif    # for gallery

      cat > /etc/php/${PHPVER}/mods-available/opcache.ini <<EOF
zend_extension=opcache.so
opcache.enable=1
opcache.enable_cli=1
opcache.fast_shutdown=1
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=10000
opcache.memory_consumption=128
opcache.save_comments=1
opcache.revalidate_freq=1
opcache.file_cache=/tmp;
EOF
      a2enconf  php${PHPVER}-fpm


      DATADIR="$( grep datadirectory /var/www/nextcloud/config/config.php | awk '{ print $3 }' | grep -oP "[^']*[^']" | head -1 )"
      UPLOADTMPDIR="$DATADIR"/tmp
      sed -i "s|^;\?upload_tmp_dir =.*$|upload_tmp_dir = $UPLOADTMPDIR|" /etc/php/${PHPVER}/cli/php.ini
      sed -i "s|^;\?upload_tmp_dir =.*$|upload_tmp_dir = $UPLOADTMPDIR|" /etc/php/${PHPVER}/fpm/php.ini
      sed -i "s|^;\?sys_temp_dir =.*$|sys_temp_dir = $UPLOADTMPDIR|"     /etc/php/${PHPVER}/fpm/php.ini

      OPCACHEDIR="$DATADIR"/.opcache
      sed -i "s|^opcache.file_cache=.*|opcache.file_cache=$OPCACHEDIR|" /etc/php/${PHPVER}/mods-available/opcache.ini

      apt-get autoremove -y

      ncc maintenance:mode --off

      bash -c "sleep 5 && service apache2 restart" &>/dev/null &
      bash -c " sleep 3
              service php${PHPVER}-fpm stop
              service mysql      stop
              sleep 0.5
              service php${PHPVER}-fpm start
              service mysql      start
              " &>/dev/null &

      } # PHP7.2 end

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
      grep -q "^\& stop" /etc/rsyslog.d/20-ufw.conf ||  echo "& stop" >> /etc/rsyslog.d/20-ufw.conf
      grep -q maxsize /etc/logrotate.d/ufw     || sed -i /weekly/amaxsize2M /etc/logrotate.d/ufw
      grep -q maxsize /etc/logrotate.d/apache2 || sed -i /weekly/amaxsize2M /etc/logrotate.d/apache2
      service rsyslog restart
      cat >> /etc/logrotate.d/ncp <<'EOF'
/var/log/ncp.log
{
        rotate 4
        size 500K
        missingok
        notifempty
        compress
}
EOF

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

