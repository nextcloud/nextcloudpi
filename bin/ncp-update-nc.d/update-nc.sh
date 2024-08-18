#!/bin/bash

set -eE${DBG}

VER="$1"
source /usr/local/etc/library.sh
export RELEASE
export PHPVER

# pre-checks
####################
BASEDIR=/var/www
cd "$BASEDIR"
DATADIR="$( get_nc_config_value datadirectory )"
ncc status &>/dev/null          || { [[ "$DBG" == x ]] && ncc status; echo "Nextcloud is currently down"; exit 1; }
[[ -d "${BASEDIR}/nextcloud-old" ]] && { echo "Nextcloud backup directory found. Interrupted or already running installation?"; exit 1; }
[[ -d "${BASEDIR}/nextcloud"     ]] || { echo "Nextcloud directory not found"      ; exit 1; }
[[ -d "$DATADIR"             ]] || { echo "Nextcloud data directory not found" ; exit 1; }

# check version
####################

[[ ${EUID} -eq 0 ]] && SUDO="sudo -u www-data"
CURRENT="$(nc_version)"
TARGET_VERSION="$(determine_nc_upgrade_version "${CURRENT?}" "${VER?}")"
[[ -n "$TARGET_VERSION" ]] || {
  echo "Could not find a valid upgrade path from '${CURRENT}' to '${TARGET_VERSION}'. Nothing to update."
  exit 1
}

MAJOR_NEW="${TARGET_VERSION%%.*}"
DEBIAN_VERSION="$(. /etc/os-release; echo "$VERSION_ID")"

if [[ "$MAJOR_NEW" -ge 24 ]] && [[ $DEBIAN_VERSION -le 10 ]]
then
  echo -e "NCP doesn't support Nextcloud versions greater than 23 with Debian 10 (Buster). Please run ncp-dist-upgrade."
  exit 1
fi

if [[ "$MAJOR_NEW" -ge 29 ]] && [[ $DEBIAN_VERSION -le 11 ]]
then
  echo -e "NCP doesn't support Nextcloud versions greater than 28 with Debian 11 (Bullseye). Please run ncp-dist-upgrade."
  exit 1
fi

grep -qP "\d+\.\d+\.\d+" <<<"$CURRENT" || { echo "Malformed version $CURRENT"; exit 1; }
grep -qP "\d+\.\d+\.\d+" <<<"$TARGET_VERSION"   || { echo "Malformed version $TARGET_VERSION"    ; exit 1; }

echo "Current   Nextcloud version $CURRENT"
echo "Available Nextcloud version $TARGET_VERSION"
if [[ "$TARGET_VERSION" != "$VER" ]]
then
  echo "INFO: You have requested an update to '$VER', but a direct update to '$VER' cannot be performed, so the latest available version that can be updated to has been selected automatically."
fi

# make sure that cron.php is not running and there are no pending jobs
# https://github.com/nextcloud/server/issues/10949
pgrep -cf cron.php &>/dev/null && { pkill -f cron.php; sleep 3; }
pgrep -cf cron.php &>/dev/null && { echo "cron.php running. Abort"; exit 1; }
mysql nextcloud <<<"UPDATE ${DB_PREFIX}jobs SET reserved_at=0;"

# cleanup
####################
cleanup() {
  local RET=$?
  set +eE
  echo "Clean up..."
  rm -rf "$BASEDIR"/nextcloud.tar.bz2 "$BASEDIR"/nextcloud-old
  trap "" EXIT
  exit $RET
}
trap cleanup EXIT

# get new code
####################
URL="https://download.nextcloud.com/server/releases/nextcloud-$TARGET_VERSION.tar.bz2"
echo "Download Nextcloud $TARGET_VERSION..."
wget -q "$URL" -O nextcloud.tar.bz2 || { echo "Error downloading"; exit 1; }

# backup
####################
BKPDIR="$BASEDIR"
WITH_DATA=no
COMPRESSED=yes
LIMIT=0

echo "Back up current instance..."
set +eE
ncp-backup "$BKPDIR" "$WITH_DATA" "$COMPRESSED" "$LIMIT" # && false # test point
RET=$?
sync
set -eE

BKP_="$( ls -1t "$BKPDIR"/nextcloud-bkp_*.tar.gz 2>/dev/null | head -1 )"
[[ -f "$BKP_"  ]] || {                set +eE; echo "Error backing up"; false || cleanup; }
[[ $RET -ne 0  ]] && { rm -f "$BKP_"; set +eE; echo "Error backing up"; false || cleanup; }
BKP="$( dirname "$BKP_" )/$( basename "$BKP_" .tar.gz )-${CURRENT}.tar.gz"
echo "Storing backup at '$BKP'..."
mv "$BKP_" "$BKP"

# simple restore if anything fails from here
####################
rollback_simple() {
  set +eE
  trap "" INT TERM HUP ERR
  echo -e "Abort\nSimple roll back..."
  rm -rf "$BASEDIR"/nextcloud
  mv "$BASEDIR"/nextcloud-old "$BASEDIR"/nextcloud
  false || cleanup                 # so cleanup exits with 1
}
trap rollback_simple INT TERM HUP ERR

# replace code
####################
echo "Install Nextcloud $TARGET_VERSION..."
mv -T nextcloud nextcloud-old
tar -xf nextcloud.tar.bz2             # && false # test point
rm -rf /var/www/nextcloud.tar.bz2

# copy old config
####################
cp nextcloud-old/config/config.php nextcloud/config/

# copy old themes
####################
cp -raT nextcloud-old/themes/ nextcloud/themes/

# copy old NCP apps
####################
for app in nextcloudpi previewgenerator; do
  if [[ -d nextcloud-old/apps/"${app}" ]]; then
    cp -r -L nextcloud-old/apps/"${app}" /var/www/nextcloud/apps/
  fi
done

#false # test point

# copy data if it was at the default location
####################
if [[ "$DATADIR" == "/var/www/nextcloud/data" ]] || [[ "$DATADIR" == "/data/nextcloud/data" ]]; then
  echo "Restore data..."
  mv -T nextcloud-old/data nextcloud/data
fi

# nc-restore if anything fails from here
####################
rollback() {
  set +eE
  trap "" INT TERM HUP ERR EXIT
  echo -e "Abort\nClean up..."
  rm -rf /var/www/nextcloud.tar.bz2 "$BASEDIR"/nextcloud-old
  echo "Rolling back to backup $BKP..."
  local TMPDATA
  mkdir -p "$BASEDIR/recovery/"
  TMPDATA="$( mktemp -d "$BASEDIR/recovery/ncp-data.XXXXXX" )" || { echo "Failed to create temp dir" >&2; exit 1; }
  [[ "$DATADIR" == "$BASEDIR/nextcloud/data" ]] && mv -T "$DATADIR" "$TMPDATA"
  ncp-restore "$BKP" || { echo "Rollback failed! Data left at $TMPDATA"; exit 1; }
  [[ "$DATADIR" == "$BASEDIR/nextcloud/data" ]] && { rm -rf "$DATADIR"; mv -T "$TMPDATA" "$DATADIR"; }
  rm "$BKP"
  echo "Rollback successful. Nothing was updated"
  exit 1
}
trap rollback INT TERM HUP ERR

# fix permissions
####################
echo "Fix permissions..."
chown -R www-data:www-data nextcloud
find nextcloud/ -type d -exec chmod 750 {} \;
find nextcloud/ -type f -exec chmod 640 {} \;

# upgrade
####################
echo "Upgrade..."
ncc='sudo -u www-data php nextcloud/occ'
$ncc upgrade      # && false # test point
$ncc | grep -q db:add-missing-indices && $ncc db:add-missing-indices -n
$ncc | grep -q db:add-missing-columns && $ncc db:add-missing-columns -n
$ncc | grep -q db:add-missing-primary-keys && $ncc db:add-missing-primary-keys -n
$ncc | grep -q db:convert-filecache-bigint && $ncc db:convert-filecache-bigint -n
$ncc maintenance:repair --help | grep -q -e '--include-expensive' && $ncc maintenance:repair --include-expensive

# use the correct version for custom apps
NCVER="$(nc_version)"
if is_more_recent_than "21.0.0" "${NCVER}"; then
  NCPREV=/var/www/ncp-previewgenerator/ncp-previewgenerator-nc20
else
  # Install notify_push if not installed
  if ! is_app_enabled notify_push; then
    ncc app:install notify_push
    ncc app:enable  notify_push
    install_template nextcloud.conf.sh /etc/apache2/sites-available/nextcloud.conf
    a2enmod proxy proxy_http proxy_wstunnel
    apachectl -k graceful
    ## make sure the notify_push daemon is runnnig

    install_template systemd/notify_push.service.sh /etc/systemd/system/notify_push.service
    start_notify_push
    nc_domain="$(ncc config:system:get overwrite.cli.url)"
    set-nc-domain "${nc_domain}" || {
      echo "notify_push setup failed. You are probably behind a proxy"
      echo "Run 'ncc config:system:set trusted_proxies 15 --value=<proxy_IP>' and then 'ncc notify_push:setup https://<domain>/push to enable"
      echo "Check https://help.nextcloud.com/tags/ncp for support"
    }

  fi
  NCPREV=/var/www/ncp-previewgenerator/ncp-previewgenerator-nc21
fi
rm -rf /var/www/nextcloud/apps/previewgenerator
ln -snf "${NCPREV}" /var/www/nextcloud/apps/previewgenerator

if ! is_more_recent_than "24.0.0" "${NCVER}" && is_more_recent_than "8.1.0" "${PHPVER}.0"
then
  /usr/local/bin/ncp-update-nc.d/upgrade-php-bullseye-8.1.sh

  # Reload library.sh to reset PHPVER
  source /usr/local/etc/library.sh
elif ! is_more_recent_than "29.0.0" "${NCVER}" && is_more_recent_than "8.3.0" "${PHPVER}.0" && [[ "$DEBIAN_VERSION" -ge 12 ]]
then
  /usr/local/bin/ncp-update-nc.d/upgrade-php-bookworm-8.3.sh

  # Reload library.sh to reset PHPVER
  source /usr/local/etc/library.sh
fi

# refresh completions
ncc _completion -g --shell-type bash -p ncc | sed 's|/var/www/nextcloud/occ|ncc|g' > /usr/share/bash-completion/completions/ncp

echo "Update completed successfully."
# done
####################
mkdir -p  "$DATADIR"/ncp-update-backups
mv "$BKP" "$DATADIR"/ncp-update-backups
chown -R www-data:www-data "$DATADIR"/ncp-update-backups
BKP="$DATADIR"/ncp-update-backups/"$( basename "$BKP" )"
echo "Backup stored at $BKP"

bash -c "sleep 5; source /usr/local/etc/library.sh; clear_opcache;" &>/dev/null &
