#!/bin/bash

# Let's encrypt certbot installation on Raspbian 
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh letsencrypt.sh <IP> (<img>)
#
# See installer.sh instructions for details
#
# More at https://ownyourbits.com/2017/03/17/lets-encrypt-installer-for-apache/

DOMAIN_=mycloud.ownyourbits.com
EMAIL_=mycloud@ownyourbits.com

NCDIR=/var/www/nextcloud
OCC="$NCDIR/occ"
VHOSTCFG=/etc/apache2/sites-available/nextcloud.conf
VHOSTCFG2=/etc/apache2/sites-available/ncp.conf
DESCRIPTION="Automatic signed SSL certificates"

INFOTITLE="Warning"
INFO="Internet access is required for this configuration to complete
Both ports 80 and 443 need to be accessible from the internet
 
Your certificate will be automatically renewed every month"

is_active()
{
  test -d /etc/letsencrypt/live
}

install()
{
  cd /etc || return 1
  apt-get update
  apt-get install --no-install-recommends -y python2.7-minimal
  git clone https://github.com/letsencrypt/letsencrypt
  /etc/letsencrypt/letsencrypt-auto --help # do not actually run certbot, only install packages

  [[ "$DOCKERBUILD" == 1 ]] && {
    # execute before lamp stack
    cat > /etc/services-available.d/009letsencrypt <<EOF
#!/bin/bash

source /usr/local/etc/library.sh
persistent_cfg /etc/letsencrypt

cat > /etc/cron.weekly/letsencrypt-ncp <<EOFCRON
#!/bin/bash
/etc/letsencrypt/certbot-auto renew --quiet
rm -rf $NCDIR/.well-known
EOFCRON

chmod +x /etc/cron.weekly/letsencrypt-ncp

exit 0
EOF
    chmod +x /etc/services-available.d/009letsencrypt
  }
}

# tested with git version v0.11.0-71-g018a304
configure() 
{
  local DOMAIN_LOWERCASE="${DOMAIN_,,}"

  grep -q ServerName $VHOSTCFG && \
    sed -i "s|ServerName .*|ServerName $DOMAIN_|" $VHOSTCFG || \
    sed -i "/DocumentRoot/aServerName $DOMAIN_" $VHOSTCFG 

  /etc/letsencrypt/letsencrypt-auto certonly -n --no-self-upgrade --webroot -w $NCDIR --hsts --agree-tos -m $EMAIL_ -d $DOMAIN_ && {
    cat > /etc/cron.weekly/letsencrypt-ncp <<EOF
#!/bin/bash
/etc/letsencrypt/certbot-auto renew --quiet
rm -rf $NCDIR/.well-known
EOF
    chmod +x /etc/cron.weekly/letsencrypt-ncp

    sed -i "s|SSLCertificateFile.*|SSLCertificateFile /etc/letsencrypt/live/$DOMAIN_LOWERCASE/fullchain.pem|" $VHOSTCFG
    sed -i "s|SSLCertificateKeyFile.*|SSLCertificateKeyFile /etc/letsencrypt/live/$DOMAIN_LOWERCASE/privkey.pem|" $VHOSTCFG

    sed -i "s|SSLCertificateFile.*|SSLCertificateFile /etc/letsencrypt/live/$DOMAIN_LOWERCASE/fullchain.pem|" $VHOSTCFG2
    sed -i "s|SSLCertificateKeyFile.*|SSLCertificateKeyFile /etc/letsencrypt/live/$DOMAIN_LOWERCASE/privkey.pem|" $VHOSTCFG2

    sudo -u www-data php $OCC config:system:set trusted_domains 4 --value=$DOMAIN_
    sudo -u www-data php $OCC config:system:set overwrite.cli.url --value=https://$DOMAIN_

    # delayed in bg so it does not kill the connection, and we get AJAX response
    bash -c "sleep 2 && service apache2 reload" &>/dev/null &
    rm -rf $NCDIR/.well-known
    
    # update configuration
    [[ "$DOCKERBUILD" == 1 ]] && update-rc.d letsencrypt enable

    return 0
  }
  rm -rf $NCDIR/.well-known
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

