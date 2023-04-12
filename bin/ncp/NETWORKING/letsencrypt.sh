#!/bin/bash

# Let's encrypt certbot installation on NextcloudPi
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at https://ownyourbits.com/2017/03/17/lets-encrypt-installer-for-apache/


ncdir=/var/www/nextcloud
nc_vhostcfg=/etc/apache2/sites-available/nextcloud.conf
ncp_vhostcfg=/etc/apache2/sites-available/ncp.conf
letsencrypt=/usr/bin/letsencrypt

is_active()
{
  [[ "${ACTIVE}" == "yes" ]] && [[ $( find /etc/letsencrypt/live/ -maxdepth 0 -empty | wc -l ) == 0 ]]
}

tmpl_letsencrypt_domain() {
  (
  . /usr/local/etc/library.sh
  if is_active_app letsencrypt; then
    find_app_param letsencrypt DOMAIN
  fi
  )
}

install()
{
  cd /etc || return 1
  apt-get update
  apt-get install --no-install-recommends -y letsencrypt
  rm -f /etc/cron.d/certbot
  mkdir -p /etc/letsencrypt/live

  is_docker && {
    # execute before lamp stack
    cat > /etc/services-available.d/009letsencrypt <<EOF
#!/bin/bash

source /usr/local/etc/library.sh
persistent_cfg /etc/letsencrypt

exit 0
EOF
    chmod +x /etc/services-available.d/009letsencrypt
  }
  return 0
}

configure()
{
  [[ "${ACTIVE}" != "yes" ]] && {
    rm -rf /etc/letsencrypt/live/*
    rm -f /etc/cron.weekly/letsencrypt-ncp
    rm -f /etc/letsencrypt/renewal-hooks/deploy/ncp
    [[ "$DOCKERBUILD" == 1 ]] && update-rc.d letsencrypt disable
    install_template nextcloud.conf.sh "${nc_vhostcfg}"
    local cert_path="$(grep SSLCertificateFile   "${nc_vhostcfg}" | awk '{ print $2 }')"
    local key_path="$(grep SSLCertificateKeyFile "${nc_vhostcfg}" | awk '{ print $2 }')"
    sed -i "s|SSLCertificateFile.*|SSLCertificateFile ${cert_path}|"      "${ncp_vhostcfg}"
    sed -i "s|SSLCertificateKeyFile.*|SSLCertificateKeyFile ${key_path}|" "${ncp_vhostcfg}"
    apachectl -k graceful
    echo "letsencrypt certificates disabled. Using self-signed certificates instead."
    exit 0
  }
  local DOMAIN_LOWERCASE="${DOMAIN,,}"

  [[ "$DOMAIN" == "" ]] && { echo "empty domain"; return 1; }

  local IFS_BK="$IFS"

  # Do it
  local domain_string=""
  for domain in "${DOMAIN}" "${OTHER_DOMAIN}"; do
    [[ "$domain" != "" ]] && {
      [[ $domain_string == "" ]] && \
        domain_string+="${domain}" || \
        domain_string+=",${domain}"
    }
  done
  "${letsencrypt}" certonly -n --cert-name "${DOMAIN}" --force-renew --no-self-upgrade --webroot -w "${ncdir}" \
    --hsts --agree-tos -m "${EMAIL}" -d "${domain_string}" && {

    # Set up auto-renewal
    cat > /etc/cron.weekly/letsencrypt-ncp <<EOF
#!/bin/bash
source /usr/local/etc/library.sh

# renew and notify
$letsencrypt renew --quiet

# notify if fails
[[ \$? -ne 0 ]] && notify_admin \
                     "SSL renewal error" \
                     "SSL certificate renewal failed. See /var/log/letsencrypt/letsencrypt.log"

# cleanup
rm -rf $ncdir/.well-known
EOF
    chmod 755 /etc/cron.weekly/letsencrypt-ncp

    mkdir -p /etc/letsencrypt/renewal-hooks/deploy
    cat > /etc/letsencrypt/renewal-hooks/deploy/ncp <<EOF
#!/bin/bash
source /usr/local/etc/library.sh
notify_admin \
  "SSL renewal" \
  "Your SSL certificate(s) \$RENEWED_DOMAINS has been renewed for another 90 days"
exit 0
EOF
    chmod +x /etc/letsencrypt/renewal-hooks/deploy/ncp

    # Configure Apache
    install_template nextcloud.conf.sh "${nc_vhostcfg}"
    local cert_path="$(grep SSLCertificateFile   "${nc_vhostcfg}" | awk '{ print $2 }')"
    local key_path="$(grep SSLCertificateKeyFile "${nc_vhostcfg}" | awk '{ print $2 }')"
    sed -i "s|SSLCertificateFile.*|SSLCertificateFile ${cert_path}|"      "${ncp_vhostcfg}"
    sed -i "s|SSLCertificateKeyFile.*|SSLCertificateKeyFile ${key_path}|" "${ncp_vhostcfg}"

    # Configure Nextcloud
    local domain_index=11
    for dom in $DOMAIN "${OTHER_DOMAINS_ARRAY[@]}"; do
      [[ "$dom" != "" ]] && {
        [[ $domain_index -lt 20 ]] || {
          echo "WARN: $dom will not be included in trusted domains for Nextcloud (maximum reached)." \
            "It will still be included in the SSL certificate"
          continue
        }
        ncc config:system:set trusted_domains "$domain_index" --value="$dom"
        ((domain_index++))
      }
    done
    set-nc-domain "$DOMAIN"

    apachectl -k graceful
    rm -rf $ncdir/.well-known

    # Update configuration
    is_docker && update-rc.d letsencrypt enable

    return 0
  }
  rm -rf $ncdir/.well-known
  return 1
}

cleanup()
{
  apt-get purge -y \
    augeas-lenses \
    libpython-dev \
    libpython2.7-dev \
    libssl-dev \
    python-dev \
    python2.7-dev \
    python-pip-whl
}


# License
#
# This script is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This script is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this script; if not, write to the
# Free Software Foundation, Inc., 59 Temple Place, Suite 330,
# Boston, MA  02111-1307  USA

