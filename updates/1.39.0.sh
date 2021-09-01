#!/bin/bash

set -e

## BACKWARD FIXES ( for older images )

source /usr/local/etc/library.sh # sets NCLATESTVER PHPVER RELEASE

# all images

## fix raspbian origin
is_active_app unattended-upgrades && run_app unattended-upgrades

## reduce cron interval to 5 minutes
crontab_tmp=$(mktemp -u -t crontab-www.XXXXXX)
echo "*/5  *  *  *  * php -f /var/www/nextcloud/cron.php" > "${crontab_tmp}"
crontab -u www-data "${crontab_tmp}"
rm "${crontab_tmp}"

## update nc-restore
install_app nc-restore

## make sure old images clear the ncp-image flag
rm -f /.ncp-image

# docker images only
[[ -f /.docker-image ]] && {
  # fix build bug on v1.32.0
  grep -q 'data-ro' /data/nextcloud/config/config.php && cp -raTn /data-ro/nextcloud /data/nextcloud
  sed -i 's|data-ro|data|' /data/nextcloud/config/config.php
  :
}

# for non docker images
[[ ! -f /.docker-image ]] && {
  :
}

## enable TLSv1.3
sed -i 's|SSLProtocol -all.*|SSLProtocol -all +TLSv1.2 +TLSv1.3|' /etc/apache2/conf-available/http2.conf
bash -c "sleep 2 && service apache2 reload" &>/dev/null &

exit 0
