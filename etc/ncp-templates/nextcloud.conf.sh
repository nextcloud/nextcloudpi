#! /bin/bash

set -e
source /usr/local/etc/library.sh
source "${BINDIR}/NETWORKING/letsencrypt.sh"

if [[ "$DOCKERBUILD" == 1 ]]
then
  source "${BINDIR}/SYSTEM/metrics.sh"
else
  tmpl_metrics_enabled(){ return 1; }
fi

echo "### DO NOT EDIT! THIS FILE HAS BEEN AUTOMATICALLY GENERATED. CHANGES WILL BE OVERWRITTEN ###"
echo ""

cat <<EOF
<IfModule mod_ssl.c>
  <VirtualHost _default_:443>
    DocumentRoot /var/www/nextcloud
EOF

LETSENCRYPT_DOMAIN="$(tmpl_letsencrypt_domain)"
if [[ "$1" != "--defaults" ]] && [[ -n "$LETSENCRYPT_DOMAIN" ]]
then
  echo "    ServerName ${LETSENCRYPT_DOMAIN}"
  LETSENCRYPT_CERT_BASE_PATH="/etc/letsencrypt/live/${LETSENCRYPT_DOMAIN,,}"
  LETSENCRYPT_CERT_PATH="${LETSENCRYPT_CERT_BASE_PATH}/fullchain.pem"
  LETSENCRYPT_KEY_PATH="${LETSENCRYPT_CERT_BASE_PATH}/privkey.pem"
else
  unset LETSENCRYPT_DOMAIN
fi

cat <<EOF
    CustomLog /var/log/apache2/nc-access.log combined
    ErrorLog  /var/log/apache2/nc-error.log
    SSLEngine on
    SSLCertificateFile      ${LETSENCRYPT_CERT_PATH:-/etc/ssl/certs/ssl-cert-snakeoil.pem}
    SSLCertificateKeyFile ${LETSENCRYPT_KEY_PATH:-/etc/ssl/private/ssl-cert-snakeoil.key}
EOF

if [[ "$1" != "--defaults" ]] && tmpl_metrics_enabled
then

  cat <<EOF
    SSLProxyEngine on

    <Location /metrics/system>
      ProxyPass http://localhost:9100/metrics

      Order deny,allow
      Allow from all
      AuthType Basic
      AuthName "Metrics"
      AuthUserFile /usr/local/etc/metrics.htpasswd
      <RequireAll>
        <RequireAny>
          Require host localhost
          Require user metrics
        </RequireAny>
      </RequireAll>

    </Location>
EOF
fi

cat <<EOF
  </VirtualHost>

  <Directory /var/www/nextcloud/>
    Options +FollowSymlinks
    AllowOverride All
    <IfModule mod_dav.c>
      Dav off
    </IfModule>
    LimitRequestBody 0
    SSLRenegBufferSize 10486000
  </Directory>
  <IfModule mod_headers.c>
    Header always set Strict-Transport-Security "max-age=15768000; includeSubDomains"
  </IfModule>
</IfModule>
EOF

apache2ctl -t