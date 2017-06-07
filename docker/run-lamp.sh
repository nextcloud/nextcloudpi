#!/bin/bash

cleanup()
{
  apachectl graceful-stop
  killall php-fpm7.0
  mysqladmin -u root -pownyourbits shutdown
  killall cron
  echo "Cleanup complete"
}

trap cleanup SIGTERM

echo "Starting PHP-fpm"
php-fpm7.0 &

echo "Starting Apache"
/usr/sbin/apache2ctl start

echo "Starting mariaDB"
mysqld &

echo "Starting cron"
cron

echo "Done"
while true; do sleep 0.5; done # do nothing, just wait for trap from 'docker stop'
