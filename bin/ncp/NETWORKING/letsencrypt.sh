#!/bin/bash

# Let's encrypt certbot installation on NextCloudPi
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at https://ownyourbits.com/2017/03/17/lets-encrypt-installer-for-apache/


ncdir=/var/www/nextcloud
vhostcfg=/etc/apache2/sites-available/nextcloud.conf
vhostcfg2=/etc/apache2/sites-available/ncp.conf
letsencrypt=/usr/bin/letsencrypt

is_active()
{
  [[ $( find /etc/letsencrypt/live/ -maxdepth 0 -empty | wc -l ) == 0 ]]
}

install()
{
  cd /etc || return 1
  apt-get update
  apt-get install --no-install-recommends -y letsencrypt
  rm -f /etc/cron.d/certbot
  mkdir -p /etc/letsencrypt/live

  [[ "$DOCKERBUILD" == 1 ]] && {
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

# tested with certbot 0.28.0
configure()
{
  local DOMAIN_LOWERCASE="${DOMAIN,,}"

  [[ "$DOMAIN" == "" ]] && { echo "empty domain"; return 1; }

  # Configure Apache
  grep -q ServerName $vhostcfg && \
    sed -i "s|ServerName .*|ServerName $DOMAIN|" $vhostcfg || \
    sed -i "/DocumentRoot/aServerName $DOMAIN" $vhostcfg

  # Do it
  $letsencrypt certonly -n --force-renew --no-self-upgrade --webroot -w $ncdir --hsts --agree-tos -m $EMAIL -d $DOMAIN && {

    # Set up auto-renewal
    cat > /etc/cron.weekly/letsencrypt-ncp <<EOF
#!/bin/bash

# renew and notify
$letsencrypt renew --quiet

# notify if fails
[[ \$? -ne 0 ]] && ncc notification:generate \
                     $NOTIFYUSER "SSL renewal error" \
                     -l "SSL certificate renewal failed. See /var/log/letsencrypt/letsencrypt.log"

# cleanup
rm -rf $ncdir/.well-known
EOF
    chmod 755 /etc/cron.weekly/letsencrypt-ncp

    mkdir -p /etc/letsencrypt/renewal-hooks/deploy
    cat > /etc/letsencrypt/renewal-hooks/deploy/ncp <<EOF
#!/bin/bash
/usr/local/bin/ncc notification:generate \
  $NOTIFYUSER "SSL renewal" \
  -l "Your SSL certificate(s) \$RENEWED_DOMAINS has been renewed for another 90 days"
exit 0
EOF
    chmod +x /etc/letsencrypt/renewal-hooks/deploy/ncp

    # Configure Apache
    sed -i "s|SSLCertificateFile.*|SSLCertificateFile /etc/letsencrypt/live/$DOMAIN_LOWERCASE/fullchain.pem|" $vhostcfg
    sed -i "s|SSLCertificateKeyFile.*|SSLCertificateKeyFile /etc/letsencrypt/live/$DOMAIN_LOWERCASE/privkey.pem|" $vhostcfg

    sed -i "s|SSLCertificateFile.*|SSLCertificateFile /etc/letsencrypt/live/$DOMAIN_LOWERCASE/fullchain.pem|" $vhostcfg2
    sed -i "s|SSLCertificateKeyFile.*|SSLCertificateKeyFile /etc/letsencrypt/live/$DOMAIN_LOWERCASE/privkey.pem|" $vhostcfg2

    # Configure Nextcloud
    ncc config:system:set trusted_domains 4 --value=$DOMAIN
    ncc config:system:set overwrite.cli.url --value=https://"$DOMAIN"/

    # delayed in bg so it does not kill the connection, and we get AJAX response
    bash -c "sleep 2 && service apache2 reload" &>/dev/null &
    rm -rf $ncdir/.well-known

    # Update configuration
    [[ "$DOCKERBUILD" == 1 ]] && update-rc.d letsencrypt enable

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

