#!/bin/bash

set -e
export NCPCFG=/usr/local/etc/ncp.cfg
source /usr/local/etc/library.sh

# Reinstall auto snapshot script to apply fix
run_app nc-snapshot-auto
