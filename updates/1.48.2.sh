#!/bin/bash

set -e

source /usr/local/etc/library.sh


is_docker || {
  arch="$(uname -m)"
  [[ "${arch}" =~ "armv7" ]] && arch="armv7"
  cat > /etc/systemd/system/notify_push.service <<EOF
[Unit]
Description = Push daemon for Nextcloud clients
After=mysql.service
After=redis.service
Requires=redis.service

[Service]
Environment=PORT=7867
Environment=NEXTCLOUD_URL=https://localhost
ExecStart=/var/www/nextcloud/apps/notify_push/bin/"${arch}"/notify_push --allow-self-signed /var/www/nextcloud/config/config.php
User=www-data

[Install]
WantedBy = multi-user.target
EOF
  start_notify_push
}

exit 0