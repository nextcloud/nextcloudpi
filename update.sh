#!/bin/bash

# Updater for NextCloudPi
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at https://ownyourbits.com/
#

source /usr/local/etc/library.sh

set -e$DBG


if is_docker
then
  echo "WARNING: Docker images should be updated by replacing the container from the latest docker image" \
    "(refer to the documentation for instructions: https://docs.nextcloudpi.com)." \
    "If you are sure that you know what you are doing, you can still execute the update script by running it like this:"
  echo "> ALLOW_UPDATE_SCRIPT=1 ncp-update"
  [[ "$ALLOW_UPDATE_SCRIPT" == "1" ]] || exit 1
fi

CONFDIR=/usr/local/etc/ncp-config.d
UPDATESDIR=updates

# don't make sense in containers
EXCL_CONTAINER="
nc-automount
nc-format-USB
nc-ramlogs
nc-swapfile
nc-static-IP
nc-wifi
nc-snapshot
nc-snapshot-auto
nc-snapshot-sync
nc-restore-snapshot
nc-hdd-monitor
nc-hdd-test
nc-zram
NFS
"

# don't make sense in a docker container
EXCL_DOCKER="
$EXCL_CONTAINER
nc-autoupdate-ncp
nc-update
nc-datadir
nc-database
UFW
nc-audit
SSH
fail2ban
nc-nextcloud
nc-init
samba
"


# check running apt or apt-get
pgrep -x "apt|apt-get" &>/dev/null && { echo "apt is currently running. Try again later";  exit 1; }

cp etc/library.sh /usr/local/etc/

source /usr/local/etc/library.sh

mkdir -p "$CONFDIR"

# prevent installing some ncp-apps in the containerized versions

EXCL_APPS=""
is_docker && EXCL_APPS="$EXCL_DOCKER"
is_lxc && EXCL_APPS="$EXCL_CONTAINER"

for opt in $EXCL_APPS; do
  touch $CONFDIR/$opt.cfg
done

# copy all files in bin and etc
cp -r bin/* /usr/local/bin/
find etc -maxdepth 1 -type f ! -path etc/ncp.cfg -exec cp '{}' /usr/local/etc \;
cp -n etc/ncp.cfg /usr/local/etc
cp -r etc/ncp-templates /usr/local/etc/

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
      id="$(jq -r ".params[$i].id" /usr/local/"$file")"
      val="$(jq -r ".params[$i].value" /usr/local/"$file")"

      for (( j = 0 ; j < len ; j++ )); do
        idnew="$(jq -r ".params[$j].id" "$file")"
        [ "$idnew" == "$id" ] && {
          cfg="$(jq ".params[$j].value = \"$val\"" "$file")"
          break
        }
      done

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

# update NCVER in ncp.cfg and nc-nextcloud.cfg (for nc-autoupdate-nc and nc-update-nextcloud)
nc_version=$(jq -r .nextcloud_version < etc/ncp.cfg)
cfg="$(jq '.' /usr/local/etc/ncp.cfg)"
cfg="$(jq ".nextcloud_version = \"$nc_version\"" <<<"$cfg")"
echo "$cfg" > /usr/local/etc/ncp.cfg

cfg="$(jq '.' etc/ncp-config.d/nc-nextcloud.cfg)"
cfg="$(jq ".params[0].value = \"$nc_version\"" <<<"$cfg")"
echo "$cfg" > /usr/local/etc/ncp-config.d/nc-nextcloud.cfg

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
mkdir -p /var/www/ncp-app
cp -r ncp-app/{appinfo,css,img,js,lib,templates} /var/www/ncp-app/

# install ncp-previewgenerator
rm -rf /var/www/ncp-previewgenerator
cp -r ncp-previewgenerator /var/www/
chown -R www-data:         /var/www/ncp-previewgenerator

# copy NC app to nextcloud directory and enable it
rm -rf /var/www/nextcloud/apps/nextcloudpi
cp -r /var/www/ncp-app /var/www/nextcloud/apps/nextcloudpi
chown -R www-data:     /var/www/nextcloud/apps/nextcloudpi

# remove unwanted ncp-apps for containerized versions
if is_docker || is_lxc; then
  for opt in $EXCL_APPS; do
    rm $CONFDIR/$opt.cfg
    find /usr/local/bin/ncp -name "$opt.sh" -exec rm '{}' \;
  done
fi

# update services for docker
if is_docker; then
  cp build/docker/{lamp/010lamp,nextcloud/020nextcloud,nextcloudpi/000ncp} /etc/services-enabled.d
fi

# only live updates from here
[[ -f /.ncp-image ]] && exit 0

# update old images
./run_update_history.sh "$UPDATESDIR"

# update to the latest NC version
is_active_app nc-autoupdate-nc && run_app nc-autoupdate-nc

start_notify_push

# Refresh ncp config values
source /usr/local/etc/library.sh

# check dist-upgrade
check_distro "$NCPCFG" && check_distro etc/ncp.cfg || {
  php_ver_new=$(jq -r '.php_version'   < etc/ncp.cfg)
  release_new=$(jq -r '.release'       < etc/ncp.cfg)

  cfg="$(jq '.' "$NCPCFG")"
  cfg="$(jq '.php_version   = "'$php_ver_new'"' <<<"$cfg")"
  cfg="$(jq '.release       = "'$release_new'"' <<<"$cfg")"
  echo "$cfg" > /usr/local/etc/ncp-recommended.cfg

  msg="Update to $release_new available. Type 'sudo ncp-dist-upgrade' to upgrade"
  echo "${msg}"
  notify_admin "New distribution available" "${msg}"
  wall "${msg}"
  cat > /etc/update-motd.d/30ncp-dist-upgrade <<EOF
#!/bin/bash
new_cfg=/usr/local/etc/ncp-recommended.cfg
[[ -f "\${new_cfg}" ]] || exit 0
echo -e "${msg}"
EOF
chmod +x /etc/update-motd.d/30ncp-dist-upgrade
}

# Remove redundant opcache configuration.
# Related to https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=815968
# Bug #416 reappeared after we moved to php7.3 and debian buster packages.
[[ "$( ls -l /etc/php/"${PHPVER}"/fpm/conf.d/*-opcache.ini 2> /dev/null |  wc -l )" -gt 1 ]] && rm "$( ls /etc/php/"${PHPVER}"/fpm/conf.d/*-opcache.ini | tail -1 )"
[[ "$( ls -l /etc/php/"${PHPVER}"/cli/conf.d/*-opcache.ini 2> /dev/null |  wc -l )" -gt 1 ]] && rm "$( ls /etc/php/"${PHPVER}"/cli/conf.d/*-opcache.ini | tail -1 )"

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
