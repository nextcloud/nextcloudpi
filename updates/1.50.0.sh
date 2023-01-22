#!/bin/bash

set -e
export NCPCFG=/usr/local/etc/ncp.cfg

bash -c "sleep 6; source /usr/local/etc/library.sh; clear_opcache" &>/dev/null &
