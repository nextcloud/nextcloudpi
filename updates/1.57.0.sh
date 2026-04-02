#!/usr/bin/env bash

set -eu

source /usr/local/etc/library.sh

ncc config:system:set serverid --value=
sudo apt-get install php${PHPVER}-apcu