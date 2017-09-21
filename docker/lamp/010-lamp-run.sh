#!/bin/bash

set -e

case "$1" in
  stop)
      apachectl graceful-stop
      killall php-fpm7.0
      mysqladmin -u root shutdown
      echo "LAMP cleanup complete"
      exit 0
    ;;
esac

echo "Starting PHP-fpm"
php-fpm7.0 &

echo "Starting Apache"
/usr/sbin/apache2ctl start

echo "Starting mariaDB"
mysqld &

exit 0
