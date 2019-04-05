#!/bin/bash

# Updater for NextCloudPi
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at https://ownyourbits.com/
#

set -e

CONFDIR=/usr/local/etc/ncp-config.d/

# don't make sense in a docker container
EXCL_DOCKER="
nc-automount
nc-format-USB
nc-datadir
nc-database
nc-ramlogs
nc-swapfile
nc-static-IP
nc-wifi
nc-nextcloud
nc-init
UFW
nc-snapshot
nc-snapshot-auto
nc-audit
nc-hdd-monitor
nc-zram
SSH
fail2ban
NFS
"

# better use a designated container
EXCL_DOCKER+="
samba
"

# check running apt
pgrep apt &>/dev/null && { echo "apt is currently running. Try again later";  exit 1; }

cp etc/library.sh /usr/local/etc/

source /usr/local/etc/library.sh

mkdir -p "$CONFDIR"

# prevent installing some ncp-apps in the docker version
[[ -f /.docker-image ]] && {
  for opt in $EXCL_DOCKER; do
    touch $CONFDIR/$opt.cfg
  done
}

# copy all files in bin and etc
cp -r bin/* /usr/local/bin/
find etc -maxdepth 1 -type f -exec cp '{}' /usr/local/etc \;

# install new entries of ncp-config and update others
for file in etc/ncp-config.d/*; do
  [ -f "$file" ] || continue;    # skip dirs

  # install new ncp_apps
  [ -f /usr/local/"$file" ] || {
    install_app "$(basename "$file" .cfg)"
  }

  # keep saved cfg values
  [ -f /usr/local/"$file" ] && {
    len="$(jq '.params | length' /usr/local/"$file")"
    for (( i = 0 ; i < len ; i++ )); do
      val="$(jq -r ".params[$i].value" /usr/local/"$file")"
      cfg="$(jq ".params[$i].value = \"$val\"" "$file")"
      echo "$cfg" > "$file"
    done
  }

  # configure if active by default
  [ -f /usr/local/"$file" ] || {
    [[ "$(jq -r ".params[0].id"    "$file")" == "ACTIVE" ]] && \
    [[ "$(jq -r ".params[0].value" "$file")" == "yes"    ]] && {
      cp "$file" /usr/local/"$file"
      run_app "$(basename "$file" .cfg)"
    }
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

# install NC app
rm -rf /var/www/ncp-app
cp -r ncp-app /var/www/

[[ -f /.docker-image ]] && {
  # remove unwanted ncp-apps for the docker version
  for opt in $EXCL_DOCKER; do
    rm $CONFDIR/$opt.cfg
    find /usr/local/bin/ncp -name "$opt.sh" -exec rm '{}' \;
  done

  # update services
  cp docker-common/{lamp/010lamp,nextcloud/020nextcloud,nextcloudpi/000ncp} /etc/services-enabled.d

}

## BACKWARD FIXES ( for older images )

# not for image builds, only live updates
[[ ! -f /.ncp-image ]] && {

  # docker images only
  [[ -f /.docker-image ]] && {
    # shouldn't be present in docker
    rm -f /usr/local/bin/ncp/SYSTEM/nc-zram.sh /usr/local/etc/ncp-config.d/nc-zram.cfg
    :
  }

  # for non docker images
  [[ ! -f /.docker-image ]] && {
    :
  }
  
  # update to the latest version
  is_active_app nc-autoupdate-nc && run_app nc-autoupdate-nc

  # configure MariaDB (UTF8 4 byte support)
  [[ -f /etc/mysql/mariadb.conf.d/91-ncp.cnf ]] || {
    cat > /etc/mysql/mariadb.conf.d/91-ncp.cnf <<EOF
[mysqld]
transaction_isolation = READ-COMMITTED
innodb_large_prefix=true
innodb_file_per_table=1
innodb_file_format=barracuda

[server]
# innodb settings
skip-name-resolve
innodb_buffer_pool_size = 256M
innodb_buffer_pool_instances = 1
innodb_flush_log_at_trx_commit = 2
innodb_log_buffer_size = 32M
innodb_max_dirty_pages_pct = 90
innodb_log_file_size = 32M

# disable query cache
query_cache_type = 0
query_cache_size = 0

# other
tmp_table_size= 64M
max_heap_table_size= 64M
EOF
    ncc maintenance:mode --on
    service mysql restart
    ncc maintenance:mode --off
  }

  # disable .user.ini
  PHPVER=7.2
  [[ -f /etc/php/${PHPVER}/fpm/conf.d/90-ncp.ini ]] || {
    MAXFILESIZE="$(grep upload_max_filesize /var/www/nextcloud/.user.ini | cut -d= -f2)"
    MEMORYLIMIT="$(grep memory_limit        /var/www/nextcloud/.user.ini | cut -d= -f2)"
    cat > /etc/php/${PHPVER}/fpm/conf.d/90-ncp.ini <<EOF
; disable .user.ini files for performance and workaround NC update bugs
user_ini.filename =

; from Nextcloud .user.ini
upload_max_filesize=$MAXFILESIZE
post_max_size=$MAXFILESIZE
memory_limit=$MEMORYLIMIT
mbstring.func_overload=0
always_populate_raw_post_data=-1
default_charset='UTF-8'
output_buffering=0

; slow transfers will be killed after this time
max_execution_time=3600
max_input_time=3600
EOF
    bash -c "sleep 3 && service php$PHPVER-fpm restart" &
  }

  # previews settings
  ncc config:app:set previewgenerator squareSizes --value="32"
  ncc config:app:set previewgenerator widthSizes  --value="128 256 512"
  ncc config:app:set previewgenerator heightSizes --value="128 256"
  ncc config:system:set jpeg_quality --value 60

  # update unattended labels
  is_active_app unattended-upgrades && run_app unattended-upgrades

  # update sury keys
  wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg

  # fix cron path
  is_active_app nc-backup-auto && run_app nc-backup-auto
  is_active_app nc-scan-auto && run_app nc-scan-auto
  is_active_app nc-autoupdate-ncp && run_app nc-autoupdate-ncp
  is_active_app nc-notify-updates && run_app nc-notify-updates
  is_active_app nc-previews-auto && run_app nc-previews-auto
  is_active_app nc-update-nc-apps-auto && run_app nc-update-nc-apps-auto

  # rework letsencrypt notification
  USER="$(jq -r '.params[2].value' "$CONFDIR"/letsencrypt.cfg)"
  mkdir -p /etc/letsencrypt/renewal-hooks/deploy/
  cat > /etc/letsencrypt/renewal-hooks/deploy/ncp <<EOF
#!/bin/bash
/usr/local/bin/ncc notification:generate $USER "SSL renewal" -l "Your SSL certificate(s) \$RENEWED_DOMAINS has been renewed for another 90 days"
EOF
  chmod +x /etc/letsencrypt/renewal-hooks/deploy/ncp

  # update nc-backup
  install_app nc-backup

  # create UPDATES section
  updates_dir=/usr/local/bin/ncp/UPDATES
  mkdir -p "$updates_dir"
  mv /usr/local/bin/ncp/{SYSTEM/unattended-upgrades.sh,CONFIG/nc-autoupdate-nc.sh,CONFIG/nc-autoupdate-ncp.sh,CONFIG/nc-update-nc-apps-auto.sh} "$updates_dir"

  # remove redundant opcache configuration. Leave until update bug is fixed -> https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=815968
  # Bug #416 reappeared after we moved to php7.2 and debian buster packages. (keep last)
  [[ "$( ls -l /etc/php/7.2/fpm/conf.d/*-opcache.ini |  wc -l )" -gt 1 ]] && rm "$( ls /etc/php/7.2/fpm/conf.d/*-opcache.ini | tail -1 )"
  [[ "$( ls -l /etc/php/7.2/cli/conf.d/*-opcache.ini |  wc -l )" -gt 1 ]] && rm "$( ls /etc/php/7.2/cli/conf.d/*-opcache.ini | tail -1 )"

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

