#!/usr/bin/env bash

set -euo pipefail

source /usr/local/etc/library.sh

# PHP-FPM systemd drop-in: allow write access to NCP paths blocked by ProtectSystem=full
# (introduced in php8.x Debian packages via systemd hardening)
install_template "systemd/php-fpm.service.d.ncp.conf.sh" \
  "/etc/systemd/system/php${PHPVER}-fpm.service.d/ncp.conf"
systemctl daemon-reload
