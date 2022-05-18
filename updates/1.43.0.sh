#!/bin/bash

set -e

## BACKWARD FIXES ( for older images )

source /usr/local/etc/library.sh # sets NCLATESTVER PHPVER RELEASE

# all images

# we handle this ourselves now
ncc app:disable updatenotification
run_app nc-notify-updates

# update nc-backup
install_app nc-backup

# fix ncp.conf bug if LE is disabled
if ! is_active_app letsencrypt; then
  if [[ -f /etc/apache2/sites-enabled/ncp.conf ]]; then
    sed -i "s|SSLCertificateFile.*|SSLCertificateFile /etc/ssl/certs/ssl-cert-snakeoil.pem|"         /etc/apache2/sites-enabled/ncp.conf
    sed -i "s|SSLCertificateKeyFile.*|SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key|" /etc/apache2/sites-enabled/ncp.conf
  fi
fi

# update nc-restore
install_app nc-restore

# docker images only
[[ -f /.docker-image ]] && {
  :
}

# for non docker images
[[ ! -f /.docker-image ]] && {

  # fix HPB with dynamic public IP
  arch="$(dpkg --print-architecture)"
  [[ "${arch}" = "armhf" ]] && arch="armv7"
  cat > /etc/systemd/system/notify_push.service <<EOF
[Unit]
Description = Push daemon for Nextcloud clients
After = mysql.service

[Service]
Environment = PORT=7867
Environment = NEXTCLOUD_URL=https://localhost
ExecStart = /var/www/nextcloud/apps/notify_push/bin/"${arch}"/notify_push --allow-self-signed /var/www/nextcloud/config/config.php
User=www-data

[Install]
WantedBy = multi-user.target
EOF
  systemctl daemon-reload
  systemctl restart notify_push

  # make sure redis is up before running nextclud-domain
  cat > /usr/lib/systemd/system/nextcloud-domain.service <<'EOF'
[Unit]
Description=Register Current IP as Nextcloud trusted domain
Requires=network.target
After=mysql.service redis.service

[Service]
ExecStart=/bin/bash /usr/local/bin/nextcloud-domain.sh
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF
}

exit 0
