#!/bin/bash

source /usr/local/etc/library.sh

set -e

NCDIR=/var/www/nextcloud
OCC="$NCDIR/occ"

[[ "$1" == "stop" ]] && {
  echo "stopping cron..."
  killall cron
  exit 0
}

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
sudo -u www-data php $OCC config:system:set trusted_domains 1 --value="$IP"

exit 0
