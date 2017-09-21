#!/bin/bash

set -e

NCDIR=/var/www/nextcloud
OCC="$NCDIR/occ"

case "$1" in
  stop)
      echo "stopping cron..."
      killall cron
      exit 0
    ;;
esac

# COPY NEXTCLOUD TO /data, WHICH WILL BE IN A PERSISTENT VOLUME (first run)
test -d /data/app || {
  echo "Setting up persistent Nextcloud dir..."
  mv "$NCDIR" /data/app
  ln -s /data/app "$NCDIR"
}

# INIT DATABASE AND NEXTCLOUD CONFIG (first run)
test -f /data/app/config/config.php || {
  echo "Uninitialized instance, running nc-init..."
  source /usr/local/etc/library.sh
  cd     /usr/local/etc/
  activate_script nc-init.sh
}

# Trusted Domain ( as an argument )
[[ "$@" != "" ]] && {
  IP=$( grep -oP '\d{1,3}(\.\d{1,3}){3}' <<< "$1" ) # validate that the first argument is a valid IP
  if [[ "$IP" != "" ]]; then
    sudo -u www-data php $OCC config:system:set trusted_domains 1 --value="$IP"
  else
    echo "First argument must be an IP address to include as a Trusted domain. Ignoring"
  fi
}

# Trusted Domain ( local IP )
IFACE=$( ip r | grep "default via" | awk '{ print $5 }' )
IP=$( ip a | grep "global $IFACE" | grep -oP '\d{1,3}(\.\d{1,3}){3}' | head -1 )
sudo -u www-data php $OCC config:system:set trusted_domains 2 --value="$IP"

echo "Starting cron"
cron

exit 0
