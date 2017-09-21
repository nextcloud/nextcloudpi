#!/bin/bash

NCDIR=/var/www/nextcloud
OCC="$NCDIR/occ"

# INIT SYSTEM CONFIG (first run)
test -d /data/etc || {
  echo "Setting up system dir..."
  #mv /etc /data/etc
  #ln -s /data/etc /etc
}

# INIT NCP CONFIG (first run)
test -d /data/ncp || {
  echo "Setting up ncp dir..."
  mv /usr/local/etc/ /data/ncp
  ln -s /data/ncp /usr/local/etc
}

# NC-INIT TODO copy all nextcloud folder?
# INIT DATABASE AND NEXTCLOUD CONFIG
  #source         /usr/local/etc/library.sh
  #activate_script /usr/local/etc/nextcloudpi-config.d/nc-init.sh

exit 0
