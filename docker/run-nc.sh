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

echo "Starting mariaDB"
mysqld &

# WAIT FOR MARIADB
while :; do
  [[ -S /var/run/mysqld/mysqld.sock ]] && break
  sleep 0.5
done

## FIRST RUN: initialize NextCloud

test -d /data/app || {

  echo "[First run]"

  # INIT DATABASE AND NEXTCLOUD CONFIG
  source         /usr/local/etc/library.sh
  install_script /usr/local/etc/nc-init.sh

  # COPY DATADIR TO /data, WHICH WILL BE IN A PERSISTENT VOLUME
  cd /var/www/nextcloud/
  echo "Setting up persistent data dir..."
  cp -ra /var/www/nextcloud/data /data/app
  sudo -u www-data php occ config:system:set datadirectory --value=/data/app

  # COPY CONFIG TO /data, WHICH WILL BE IN A PERSISTENT VOLUME
  echo "Setting up persistent configuration..."
  test -e /data/config || mv /var/www/nextcloud/config /data
}

# Use persistent configuration
test -e /data/config && {
  rm -rf /var/www/nextcloud/config
  ln -s /data/config /var/www/nextcloud/config
}

cd /var/www/nextcloud/

# Trusted Domain ( as an argument )
[[ "$@" != "" ]] && {
  IP=$( grep -oP '\d{1,3}(.\d{1,3}){3}' <<< "$1" ) # validate that the first argument is a valid IP
  if [[ "$IP" != "" ]]; then
    sudo -u www-data php occ config:system:set trusted_domains 1 --value=$IP
  else
    echo "First argument must be an IP address to include as a Trusted domain. Ignoring"
  fi
}

# Trusted Domain ( local IP )
IFACE=$( ip r | grep "default via" | awk '{ print $5 }' )
IP=$( ip a | grep "global $IFACE" | grep -oP '\d{1,3}(.\d{1,3}){3}' | head -1 )
sudo -u www-data php occ config:system:set trusted_domains 2 --value=$IP

echo "Starting Apache"
/usr/sbin/apache2ctl start

echo "Starting cron"
cron

echo "Done"
while true; do sleep 0.5; done # do nothing, just wait for trap from 'docker stop'
