#!/usr/bin/env bash

source /usr/local/etc/library.sh

echo "Upgrading PHP..."
export DEBIAN_FRONTEND=noninteractive
PHPVER_OLD="$PHPVER"
PHPVER_NEW="8.3"
PHP_PACKAGES_OLD=("php${PHPVER_OLD}" \
  "php${PHPVER_OLD}"-{curl,gd,fpm,cli,opcache,mbstring,xml,zip,fileinfo,ldap,intl,bz2,mysql,bcmath,gmp,redis,common})
PHP_PACKAGES_NEW=("php${PHPVER_NEW}" \
  "php${PHPVER_NEW}"-{curl,gd,fpm,cli,opcache,mbstring,xml,zip,fileinfo,ldap,intl,bz2,mysql,bcmath,gmp,redis,common})

php_restore() {
  trap "" INT TERM HUP ERR
  echo "Something went wrong while upgrading PHP. Rolling back to version ${PHPVER_OLD}..."
  set +e
  service "php${PHPVER_NEW}-fpm" stop
  a2disconf php${PHPVER_NEW}-fpm
  wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
  echo "deb https://packages.sury.org/php/ ${RELEASE%-security} main" > /etc/apt/sources.list.d/php.list
  apt-get update
  apt-get remove --purge -y "${PHP_PACKAGES_NEW[@]}"
  apt-get install -y --no-install-recommends -t "$RELEASE" "${PHP_PACKAGES_OLD[@]}"
  set_ncpcfg "php_version" "${PHPVER_OLD}"
  install_template "php/opcache.ini.sh" "/etc/php/${PHPVER_NEW}/mods-available/opcache.ini"
  run_app nc-limits
  a2enconf "php${PHPVER_OLD}-fpm"
  service "php${PHPVER_OLD}-fpm" start
  service apache2 restart
  echo "PHP upgrade has been successfully reverted"
  set -e
}

trap php_restore INT TERM HUP ERR

apt-get update

clear_opcache

echo "Stopping apache and  php-fpm..."
service "php${PHPVER_OLD}-fpm" stop
service apache2 stop

echo "Remove old PHP (${PHPVER_OLD})..."
a2disconf "php${PHPVER_OLD}-fpm"

apt-get remove --purge -y "${PHP_PACKAGES_OLD[@]}"

echo "Install PHP ${PHPVER_NEW}..."
install_with_shadow_workaround --no-install-recommends systemd
apt-get install -y --no-install-recommends -t "$RELEASE" "${PHP_PACKAGES_NEW[@]}"

set_ncpcfg "php_version" "${PHPVER_NEW}"
install_template "php/opcache.ini.sh" "/etc/php/${PHPVER_NEW}/mods-available/opcache.ini"
( set -e; export PHPVER="${PHPVER_NEW}"; run_app nc-limits )

a2enconf "php${PHPVER_NEW}-fpm"

echo "Starting apache and php-fpm..."
service "php${PHPVER_NEW}-fpm" start
service apache2 start
ncc status
rm -f /etc/apt/sources.list.d/php.list /etc/apt/trusted.gpg.d/php.gpg