#!/usr/bin/env bash

set -euo pipefail

source /usr/local/etc/library.sh

echo "Configuring serverid ..."
old_id="$(ncc config:system:get serverid)"
[[ "$old_id" -lt 512 ]] || ncc config:system:set serverid --value="$((RANDOM % 512))" --type=integer

[[ -f "/etc/php/${PHPVER}/mods-available/opcache.ini" ]] \
  || install_template "php/opcache.ini.sh" "/etc/php/${PHPVER}/mods-available/opcache.ini"

OPCACHE_FOUND=0
for ini in /etc/php/"${PHPVER}"/fpm/conf.d/*opcache.ini;
do
  if [[ -L "$ini" ]]
  then
    OPCACHE_FOUND=1
  fi
done
if [[ "$OPCACHE_FOUND" != 1 ]]
then
  phpenmod -v "${PHPVER}" -s fpm opcache
fi
