#!/usr/bin/env bash

set -eu

source /usr/local/etc/library.sh

echo "Configuring serverid ..."
ncc config:system:get serverid > /dev/null || ncc config:system:set serverid --value="$((RANDOM % 1024))" --type=integer
echo "Installing PHP APCU ..."
sudo apt-get install -y php${PHPVER}-apcu
echo "Enable apache2 remoteip"
a2enmod remoteip
install_template nextcloud.conf.sh /etc/apache2/sites-available/001-nextcloud.conf --allow-fallback || {
  echo "ERROR: Parsing template failed. Nextcloud will not work."
  exit 1
}
systemctl reload apache2

if [[ -L /var/www/nextcloud/apps/previewgenerator ]]
then
  echo "Removing custom version of previewgenerator app ..."
  ncc app:remove previewgenerator || :;
  rm -f /var/www/nextcloud/apps/previewgenerator
  rm -rf /var/www/ncp-previewgenerator
fi

if [[ -f "/etc/cron.d/nc-previews-auto" ]]
then
  echo "Migrate nc-previews(-auto) to v1.57.0 ..."

  echo "Reconfigure automatic preview generation"
  run_app nc-previews-auto

  echo "Rerun initial preview generation ..."
  set_app_param nc-previews CLEAN yes
  set_app_param nc-previews INCREMENTAL no
  set_app_param nc-previews PATH1 ""

  PREVIEW_GENERATION_DETACH=true run_app nc-previews
  echo "Initial preview generation job started in background. You can view it's progress by running the nc-previews app from the NCP web UI."
  rm /etc/cron.d/nc-previews-auto
  echo "Done."
fi
