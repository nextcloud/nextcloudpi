#!/bin/bash

set -e

## BACKWARD FIXES ( for older images )

source /usr/local/etc/library.sh # sets NCLATESTVER PHPVER RELEASE

# all images

# update ncp-restore
install_app nc-restore

# fix letsencrypt with httpsonly enabled
  cat > /etc/apache2/sites-available/000-default.conf <<'EOF'
<VirtualHost _default_:80>
  DocumentRoot /var/www/nextcloud
  <IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteRule ^.well-known/acme-challenge/ - [L]
    RewriteCond %{HTTPS} !=on
    RewriteRule ^/?(.*) https://%{SERVER_NAME}/$1 [R,L]
  </IfModule>
  <Directory /var/www/nextcloud/>
    Options +FollowSymlinks
    AllowOverride All
    <IfModule mod_dav.c>
      Dav off
    </IfModule>
    LimitRequestBody 0
  </Directory>
</VirtualHost>
EOF
  apachectl -k graceful

# fix issue with reverse proxy infinite redirections
run_app nc-httpsonly
ncc config:system:set overwriteprotocol --value="https"

# bash completion for `ncc`
if ! [[ -f /usr/share/bash-completion/completions/ncp ]]; then
  apt_install bash-completion
  ncc _completion -g --shell-type bash -p ncc | sed 's|/var/www/nextcloud/occ|ncc|g' > /usr/share/bash-completion/completions/ncp
  echo ". /etc/bash_completion" >> /etc/bash.bashrc
  echo ". /usr/share/bash-completion/completions/ncp" >> /etc/bash.bashrc
  cat > /usr/local/bin/ncc <<'EOF'
#!/bin/bash
sudo -E -u www-data php /var/www/nextcloud/occ "$@"
EOF
  chmod +x /usr/local/bin/ncc
fi

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
