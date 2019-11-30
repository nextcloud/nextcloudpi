#!/bin/bash

set -e

## BACKWARD FIXES ( for older images )

source /usr/local/etc/library.sh # sets NCVER PHPVER RELEASE

# all images

# replace preview generator for the NCP version
[[ -d /var/www/nextcloud/apps/previewgenerator ]] && {
  grep -q NCP /var/www/nextcloud/apps/previewgenerator &>/dev/null || {
    cp -raT /var/www/nextcloud/apps/{previewgenerator,previewgenerator.orig}
    cp -r /var/www/ncp-previewgenerator /var/www/nextcloud/apps/previewgenerator
    chown -R www-data: /var/www/nextcloud/apps/previewgenerator
    is_active_app nc-previews-auto && run_app nc-previews-auto
  }
}

# if using NCP original logo, replace with the new version
datadir=$(ncc config:system:get datadirectory)
id=$(grep instanceid /var/www/nextcloud/config/config.php | awk -F "=> " '{ print $2 }' | sed "s|[,']||g")
sum_orig=ca39ff587bd899cb92eb0f5a6d429824
sum_curr=$(md5sum "${datadir}"/appdata_*/theming/images/logo | awk '{ print $1 }')
[[ "${sum_orig}" == "${sum_curr}" ]] && {
  cp etc/logo "${datadir}/appdata_${id}/theming/images/logo"
  cp etc/logo "${datadir}/appdata_${id}/theming/images/logoheader"
}

# docker images only
[[ -f /.docker-image ]] && {
  :
}

# for non docker images
[[ ! -f /.docker-image ]] && {
  :
}

exit 0
