#!/usr/bin/env bash

set -eu

source /usr/local/etc/library.sh

echo "Configuring serverid ..."
ncc config:system:get serverid > /dev/null || ncc config:system:set serverid --value="$((RANDOM % 1024))" --type=integer
echo "Installing PHP APCU ..."
sudo apt-get install -y php${PHPVER}-apcu

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

  run_app nc-previews
  echo "Done."
fi