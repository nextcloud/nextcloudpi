#!/bin/bash

source /usr/local/etc/library.sh

set -e

[[ "$1" == "stop" ]] && {
  echo "Stopping apache"
  apachectl graceful-stop
  echo "Stopping PHP-fpm"
  killall php-fpm7.0
  echo "Stopping mariaDB"
  mysqladmin -u root shutdown
  echo "LAMP cleanup complete"
  exit 0
}

# MOVE CONFIGS TO PERSISTENT VOLUME
persistent_cfg /etc/apache2

echo "Starting PHP-fpm"
php-fpm7.0 &

echo "Starting Apache"
/usr/sbin/apache2ctl start

echo "Starting mariaDB"
mysqld &

# wait for mariadb
while :; do
  [[ -S /var/run/mysqld/mysqld.sock ]] && break
  sleep 0.5
done

exit 0
