#!/usr/bin/env bash

source /usr/local/etc/library.sh

jq '.params[].id' "$CFGDIR/nc-backup-auto.cfg" | grep BACKUPHOUR || \
  set_app_param nc-backup-auto BACKUPHOUR 3
