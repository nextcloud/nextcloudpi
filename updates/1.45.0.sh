#!/bin/bash

set -e

## BACKWARD FIXES ( for older images )

source /usr/local/etc/library.sh # sets NCLATESTVER PHPVER RELEASE

# all images

# this update brings a version bump for ncp-previewgenerator
ncc upgrade

# update ncc
cat > /usr/local/bin/ncc <<'EOF'
#!/bin/bash
[[ ${EUID} -eq 0 ]] && SUDO="sudo -E -u www-data"
${SUDO} php /var/www/nextcloud/occ "$@"
EOF
chmod +x /usr/local/bin/ncc

# docker images only
[[ -f /.docker-image ]] && {
  :
}

# for non docker images
[[ ! -f /.docker-image ]] && {

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
