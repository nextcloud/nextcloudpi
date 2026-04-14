#!/usr/bin/env bash
set -eu

source /usr/local/etc/library.sh

echo "Reconfigure automatic preview generation (if enabled)"
run_app nc-previews-auto