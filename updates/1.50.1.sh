#!/bin/bash

set -e
export NCPCFG=/usr/local/etc/ncp.cfg
source /usr/local/etc/library.sh

install_template systemd/notify_push.service.sh /etc/systemd/system/notify_push.service

if is_docker
then

  echo "Upgrading PHP..."
  export DEBIAN_FRONTEND=noninteractive
  PHPVER_OLD="7.4"
  PHPVER_NEW="8.1"

  php_restore() {
    trap "" INT TERM HUP ERR
    echo "Something went wrong while upgrading PHP. Rolling back..."
    set +e
    a2disconf php${PHPVER_NEW}-fpm
    set_ncpcfg "php_version" "${PHPVER_OLD}"
    install_template "php/opcache.ini.sh" "/etc/php/${PHPVER_OLD}/mods-available/opcache.ini"
    clear_opcache
    run_app nc-limits
    a2enconf "php${PHPVER_OLD}-fpm"
    service "php${PHPVER_OLD}-fpm" start
    service apache2 restart
    echo "PHP upgrade has been reverted. Please downgrade to the previous docker image"
  }

  trap php_restore INT TERM HUP ERR

  # Setup apt repository for php 8

  a2disconf "php${PHPVER_OLD}-fpm"
  set_ncpcfg "php_version" "${PHPVER_NEW}"
  install_template "php/opcache.ini.sh" "/etc/php/${PHPVER_NEW}/mods-available/opcache.ini"
  ( set -e; export PHPVER="${PHPVER_NEW}"; run_app nc-limits )
  clear_opcache
  a2enconf "php${PHPVER_NEW}-fpm"
  service "php${PHPVER_NEW}-fpm" start
  service apache2 restart

else

  clear_opcache
  bash -c "sleep 6; service php${PHPVER}-fpm restart" &>/dev/null &
fi
