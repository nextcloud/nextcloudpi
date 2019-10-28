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

# docker images only
[[ -f /.docker-image ]] && {
  :
}

# for non docker images
[[ ! -f /.docker-image ]] && {
  :
}

exit 0
