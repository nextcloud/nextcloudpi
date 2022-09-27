#! /bin/bash

set -e
source /usr/local/etc/library.sh

cat <<EOF
[Unit]
Description = Push daemon for Nextcloud clients
After=mysql.service
After=redis.service
Requires=redis.service

[Service]
Environment=PORT=7867
Environment=NEXTCLOUD_URL=https://localhost
ExecStart="/var/www/nextcloud/apps/notify_push/bin/${ARCH}/notify_push" --allow-self-signed /var/www/nextcloud/config/config.php
User=www-data
Restart=on-failure
RestartSec=20

[Install]
WantedBy = multi-user.target
EOF
