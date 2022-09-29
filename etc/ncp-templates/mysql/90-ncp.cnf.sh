#! /bin/bash

set -e
source /usr/local/etc/library.sh

if [[ "$1" == "--defaults" ]]
then
  echo "INFO: Restoring template to default settings" >&2
  DB_DIR=/var/lib/mysql
else
  if is_docker && [[ -f /.ncp-image ]]
  then
    echo "INFO: Docker build detected." >&2
    DB_DIR=/data-ro/database
  elif is_docker
  then
    echo "INFO: Docker container detected." >&2
    DB_DIR=/data/database
  else
    DB_DIR="$(source "${BINDIR}/CONFIG/nc-database.sh"; tmpl_db_dir)"
  fi
fi

# configure MariaDB (UTF8 4 byte support)
cat <<EOF
[mysqld]
datadir = ${DB_DIR?}
EOF
