#!/bin/bash

source /usr/local/etc/library.sh

NCDIR=/var/www/nextcloud
OCC="$NCDIR/occ"

# INIT NCP CONFIG (first run)
persistent_cfg /usr/local/etc/nextcloudpi-config.d /data/ncp

exit 0
