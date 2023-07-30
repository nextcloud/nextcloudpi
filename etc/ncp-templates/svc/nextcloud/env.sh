#!/usr/bin/env bash

source /usr/local/etc/library.sh

find_current() {
  [[ -f /usr/local/etc/svc/nextcloud/.env ]] || return 1
  (
    local VARNAME="${1?}"
    source /usr/local/etc/svc/nextcloud/.env
    echo -n "${!VARNAME}"
    [[ -n "${!VARNAME}" ]]
  )
}

if [[ "$1" == "--defaults" ]]
then
  echo "INFO: Restoring template to default settings" >&2
  DB_DIR=/opt/data/ncdatabase
  DATA_DIR=/opt/data/ncdata
  NC_VERSION="$(find_current "$NC_VERSION"    || jq -r '.nextcloud_version' /usr/local/etc/ncp.cfg)"
  DB_PW="$(base64 < /dev/urandom | head -c 32)"
  DB_ROOT_PW="$(base64 < /dev/urandom | head -c 32)"
  REDIS_PASSWORD="$(base64 < /dev/urandom | head -c 32)"
else
  DB_DIR="$(source "${BINDIR}/CONFIG/nc-database.sh"; tmpl_db_dir)"
  DATA_DIR="$(source "${BINDIR}/CONFIG/nc-datadir.sh"; tmpl_data_dir)"
  [[ -n "$NC_VERSION" ]]     || NC_VERSION="$(find_current "$NC_VERSION"        || jq -r '.nextcloud_version' /usr/local/etc/ncp.cfg)"
  [[ -n "$DB_PW" ]]          || DB_PW="$(find_current "DB_PW"                   || base64 < /dev/urandom | head -c 32)"
  [[ -n "$DB_ROOT_PW" ]]     || DB_ROOT_PW="$(find_current "DB_ROOT_PW"         || base64 < /dev/urandom | head -c 32)"
  [[ -n "$REDIS_PASSWORD" ]] || REDIS_PASSWORD="$(find_current "REDIS_PASSWORD" || base64 < /dev/urandom | head -c 32)"
fi

cat <<EOF
NC_VERSION=${NC_VERSION}
MARIADB_VERSION=10
DB_DIRECTORY=${DB_DIR}
DATA_DIRECTORY=${DATA_DIR}
DB_PASSWORD=${DB_PW}
DB_ROOT_PASSWORD=${DB_ROOT_PW}
REDIS_PASSWORD=${REDIS_PASSWORD}
PHP_MEMORY_LIMIT=512M
PHP_UPLOAD_LIMIT=10G
CFG_DIR=/usr/local/etc/config
EOF
