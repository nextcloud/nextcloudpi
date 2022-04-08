#!/bin/bash

set -e

# Stop metrics services if running
for svc in prometheus-node-exporter ncp-metrics-exporter
do
  service "$svc" status || [[ $? -ne 4 ]] || continue
  service "$svc" stop
done

# Reinstall metrics services
source /usr/local/etc/library.sh
install_app metrics
is_active_app metrics && (
  export METRICS_SKIP_PASSWORD_CONFIG=true
  run_app metrics
)

exit 0
