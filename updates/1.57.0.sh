#!/usr/bin/env bash

set -eu

source /usr/local/etc/library.sh

echo "Configuring serverid ..."
ncc config:system:set serverid --value="$((RANDOM % 1024))" --type=integer
echo "Installing PHP APCU ..."
sudo apt-get install -y php${PHPVER}-apcu

echo "Removing custom version of previewgenerator app ..."
ncc app:remove previewgenerator || :;
rm -f /var/www/nextcloud/apps/previewgenerator
rm -rf /var/www/ncp-previewgenerator

echo "INFO: You can now setup the latest version of the previewgenerator app including background generation of previews from the NCP admin UI."