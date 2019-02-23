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

  # fix Armbian cron bug
  [[ "$( ls -1 /etc/cron.d/ |  wc -l )" -gt 0 ]] && chmod 644 /etc/cron.d/*
  [[ "$( ls -1 /etc/cron.daily/ |  wc -l )" -gt 0 ]] && chmod 755 /etc/cron.daily/*
  [[ "$( ls -1 /etc/cron.hourly/ |  wc -l )" -gt 0 ]] && chmod 755 /etc/cron.hourly/*

  # change letsencrypt from package based to git based
  [[ -f /etc/letsencrypt/certbot-auto ]] || {
    echo "updating letsencrypt..."
    [[ -f /.docker-image ]] && mv "$(readlink /etc/letsencrypt)" /etc/letsencrypt-old
    [[ -f /.docker-image ]] || mv /etc/letsencrypt /etc/letsencrypt-old
    rm -f /etc/letsencrypt
    apt-get remove -y letsencrypt
    apt-get autoremove -y
    install_app letsencrypt || { rm -rf /etc/letsencrypt; mv /etc/letsencrypt-old /etc/letsencrypt; exit 1; }
    [[ -f /etc/letsencrypt-old/live ]] && cp -raT /etc/letsencrypt-old/live /etc/letsencrypt/live
    [[ -f /.docker-image ]] && persistent_cfg /etc/letsencrypt
    [[ -f /etc/cron.weekly/letsencrypt-ncp ]] && run_app letsencrypt
  }

  # fix LE update bug
  [[ -d /etc/letsencrypt/archive ]] || {
    sleep 3
    cp -ravT /etc/letsencrypt-old/archive /etc/letsencrypt/archive &>/dev/null || true
    bash -c "sleep 2 && service apache2 reload" &>/dev/null &
  }

  # fix LE update bug (2)
  if [[ -d /etc/letsencrypt/archive ]] && [[ "$(ls /etc/letsencrypt/archive/* 2>/dev/null | wc -l )" == "0" ]]; then
    rmdir /etc/letsencrypt/archive
    sleep 3
    cp -ravT /etc/letsencrypt-old/archive /etc/letsencrypt/archive &>/dev/null || true
    bash -c "sleep 2 && service apache2 reload" &>/dev/null &
  fi

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

