#!/usr/bin/env bash

source /usr/local/etc/library.sh

# Fix NCP theme
[[ -e /usr/local/etc/logo ]] && {
  echo "Fixing NCP logo if missing..."
  ID=$( grep instanceid /var/www/nextcloud/config/config.php | awk -F "=> " '{ print $2 }' | sed "s|[,']||g" )
  [[ "$ID" == "" ]] && { echo "failed to get ID"; exit 1; }
  theming_base_path="$( get_nc_config_value datadirectory )/appdata_${ID}/theming/global/images"
  mkdir -p "${theming_base_path}"
  [ -f "${theming_base_path}/background" ] || cp /usr/local/etc/background "${theming_base_path}/background"
  [ -f "${theming_base_path}/logo" ] || cp /usr/local/etc/logo "${theming_base_path}/logo"
  [ -f "${theming_base_path}/logoheader" ] || cp /usr/local/etc/logo "${theming_base_path}/logoheader"
  chown -R www-data:www-data "$( get_nc_config_value datadirectory )/appdata_${ID}"
  echo "Done."
}
