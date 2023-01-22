#!/bin/bash

set -e

source /usr/local/etc/library.sh

dpkg -l | grep -e '^ii' | grep -e 'php-json' > /dev/null && {
  apt-get remove -y php-json
}

echo "Updating opcache configuration..."
install_template "php/opcache.ini.sh" "/etc/php/${PHPVER}/mods-available/opcache.ini"

dpkg -l | grep -e '^ii' | grep -e 'php8.2' > /dev/null && {
  msg="PHP 8.2 packages have been detected on your ncp instance, which could cause issues. If you didn't install them on purpose, please remove them with the following command: sudo apt remove php8.2-*"
  echo -e "$msg"
  notify_admin "NextcloudPi" "$msg"
}

bash -c "sleep 5; source /usr/local/etc/library.sh; clear_opcache; service php${PHPVER}-fpm restart;" &> /dev/null &

exit 0
