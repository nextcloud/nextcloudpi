#!/bin/bash

source /usr/local/etc/library.sh

set -e

NCDIR=/var/www/nextcloud
OCC="$NCDIR/occ"

[[ "$1" == "stop" ]] && {
  echo "stopping cron..."
  killall cron
  echo "stopping redis..."
  killall redis-server
  exit 0
}

echo "Starting Redis"
mkdir -p /var/run/redis
chown redis /var/run/redis
sudo -u redis redis-server /etc/redis/redis.conf

echo "Starting cron"
cron

# INIT DATABASE AND NEXTCLOUD CONFIG (first run)
test -f /data/app/config/config.php || {
  echo "Uninitialized instance, running nc-init..."
  source /usr/local/etc/library.sh
  cd     /usr/local/etc/
  activate_script nc-init.sh
}

# Trusted Domain ( local IP )
IFACE=$( ip r | grep "default via" | awk '{ print $5 }' )
IP=$( ip a | grep "global $IFACE" | grep -oP '\d{1,3}(\.\d{1,3}){3}' | head -1 )
sudo -u www-data php "$OCC" config:system:set trusted_domains 1 --value="$IP"

# Trusted Domain ( as an argument )
[[ "$@" != "" ]] && {
  IP=$( grep -oP '\d{1,3}(\.\d{1,3}){3}' <<< "$2" ) # validate that the first argument is a valid IP
  if [[ "$IP" != "" ]]; then
    sudo -u www-data php "$OCC" config:system:set trusted_domains 6 --value="$IP"
  else
    echo "First argument must be an IP address to include as a Trusted domain. Ignoring"
  fi
}

exit 0
