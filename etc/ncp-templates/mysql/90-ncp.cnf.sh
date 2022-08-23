#! /bin/bash

set -e
source /usr/local/etc/library.sh

if [[ "$1" == "--defaults" ]]
then
  echo -e "INFO: Restoring template to default settings"
  DB_DIR=/var/lib/mysql
else
  if [[ "$DOCKERBUILD" -eq 1 ]]
  then
    echo -e "INFO: Docker build detected."
    DB_DIR=/data-ro/database
  elif is_docker
  then
    echo -e "INFO: Docker container detected."
    DB_DIR=/data/database
  else
    DB_DIR="$(source "${BINDIR}/CONFIG/nc-database.sh"; tmpl_db_dir)"
  fi
fi

# configure MariaDB (UTF8 4 byte support)
cat > /etc/mysql/mariadb.conf.d/90-ncp.cnf <<EOF
[mysqld]
datadir = ${DB_DIR?}
EOF
