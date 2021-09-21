#! /bin/bash

set -e
source /usr/local/etc/library.sh

[[ "$1" != "--defaults" ]] || echo "INFO: Restoring template to default settings" >&2
[[ ! -f /.docker-image ]] || echo "INFO: Docker installation detected" >&2

if [[ "$1" != "--defaults" ]]; then
  LETSENCRYPT_DOMAIN="$(
    # force defaults during initial build
    if ! [[ -f /.ncp-image ]]; then
      source "${BINDIR}/NETWORKING/letsencrypt.sh"
      tmpl_letsencrypt_domain
    fi
  )"
fi

[[ -z "$LETSENCRYPT_DOMAIN" ]] || echo "INFO: Letsencrypt domain is ${LETSENCRYPT_DOMAIN}" >&2

if [[ ! -f /.docker-image ]] && [[ "$1" != "--defaults" ]]; then
  METRICS_IS_ENABLED="$(
  source "${BINDIR}/SYSTEM/metrics.sh"
  tmpl_metrics_enabled && echo yes || echo no
  )"
else
  METRICS_IS_ENABLED=no
fi

echo "INFO: Metrics enabled: ${METRICS_IS_ENABLED}" >&2

echo "### DO NOT EDIT! THIS FILE HAS BEEN AUTOMATICALLY GENERATED. CHANGES WILL BE OVERWRITTEN ###"
echo ""

cat <<EOF
<IfModule mod_ssl.c>
  <VirtualHost _default_:443>
    DocumentRoot /var/www/nextcloud
EOF

if [[ "$1" != "--defaults" ]] && [[ -n "$LETSENCRYPT_DOMAIN" ]]; then
  echo "    ServerName ${LETSENCRYPT_DOMAIN}"
  LETSENCRYPT_CERT_BASE_PATH="$(dirname "$(letsencrypt certificates 2>/dev/null | head -1 | grep 'Certificate Path' | sed 's|.*: ||')")"
  LETSENCRYPT_CERT_PATH="${LETSENCRYPT_CERT_BASE_PATH}/fullchain.pem"
  LETSENCRYPT_KEY_PATH="${LETSENCRYPT_CERT_BASE_PATH}/privkey.pem"
else
  # Make sure the default snakeoil cert exists
  [ -f /etc/ssl/certs/ssl-cert-snakeoil.pem ] || make-ssl-cert generate-default-snakeoil --force-overwrite
  unset LETSENCRYPT_DOMAIN
fi

cat <<EOF
    CustomLog /var/log/apache2/nc-access.log combined
    ErrorLog  /var/log/apache2/nc-error.log
    SSLEngine on
    SSLProxyEngine on
    SSLCertificateFile      ${LETSENCRYPT_CERT_PATH:-/etc/ssl/certs/ssl-cert-snakeoil.pem}
    SSLCertificateKeyFile ${LETSENCRYPT_KEY_PATH:-/etc/ssl/private/ssl-cert-snakeoil.key}

    # For notify_push app in NC21
    ProxyPass /push/ws ws://127.0.0.1:7867/ws
    ProxyPass /push/ http://127.0.0.1:7867/
    ProxyPassReverse /push/ http://127.0.0.1:7867/
EOF

if [[ "$1" != "--defaults" ]] && [[ "$METRICS_IS_ENABLED" == yes ]]
then

  cat <<EOF

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
          Require valid-user
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

echo "Apache self check:" >&2
apache2ctl -t >&2
