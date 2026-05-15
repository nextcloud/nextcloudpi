#!/bin/bash

# systemd drop-in for php-fpm to allow write access to NCP paths
# that are otherwise blocked by ProtectSystem=full in the upstream
# php-fpm service unit (introduced in php8.x Debian packages).
#
# ProtectSystem=full makes /usr, /boot and /etc read-only for the
# php-fpm process. ReadWritePaths carves out explicit exceptions.

set -e
source /usr/local/etc/library.sh

cat <<EOF
[Service]
ReadWritePaths=/usr/local/etc/ncp-config.d
ReadWritePaths=/var/www/ncp-web
EOF
