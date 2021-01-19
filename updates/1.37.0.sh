#!/bin/bash

set -e

## BACKWARD FIXES ( for older images )

source /usr/local/etc/library.sh # sets NCVER PHPVER RELEASE

# all images

## fix raspbian origin
is_active_app unattended-upgrades && run_app unattended-upgrades

## reduce cron interval to 5 minutes
crontab_tmp=$(mktemp -u -t crontab-www.XXXXXX)
echo "*/5  *  *  *  * php -f /var/www/nextcloud/cron.php" > "${crontab_tmp}"
crontab -u www-data "${crontab_tmp}"
rm "${crontab_tmp}"


# docker images only
[[ -f /.docker-image ]] && {
  # fix build bug on v1.32.0
  sed -i 's|data-ro|data|' /data/nextcloud/config/config.php
  :
}

# for non docker images
[[ ! -f /.docker-image ]] && {
  :
}

exit 0
