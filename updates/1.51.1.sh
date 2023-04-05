#!/usr/bin/env bash

# Fix NCP theme
[[ -e /usr/local/etc/logo ]] && {
  ID=$( grep instanceid /var/www/nextcloud/config/config.php | awk -F "=> " '{ print $2 }' | sed "s|[,']||g" )
  [[ "$ID" == "" ]] && { echo "failed to get ID"; exit 1; }
  theming_base_path="data/appdata_${ID}/theming/global/images"
  mkdir -p "${theming_base_path}"
  [ -f "${theming_base_path}/background" ] || cp /usr/local/etc/background "${theming_base_path}/background"
  [ -f "${theming_base_path}/logo" ] || cp /usr/local/etc/logo "${theming_base_path}/logo"
  [ -f "${theming_base_path}/logoheader" ] || cp /usr/local/etc/logo "${theming_base_path}/logoheader"
  chown -R www-data:www-data "data/appdata_${ID}"
}
