#!/bin/bash

# Updaterfor  NextCloudPi
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at https://ownyourbits.com/
#

CONFDIR=/usr/local/etc/nextcloudpi-config.d/

# don't make sense in a docker container
EXCL_DOCKER="
nc-automount.sh
nc-format-USB.sh
nc-datadir.sh
nc-database.sh
nc-ramlogs.sh
nc-swapfile.sh
nc-static-IP.sh
nc-wifi.sh
nc-nextcloud.sh
nc-init.sh
"

# better use a designated container
EXCL_DOCKER+="
samba.sh
NFS.sh
"

# TODO review systemd timers
EXCL_DOCKER+="
nc-notify-updates.sh
nc-scan-auto.sh
nc-backup-auto.sh
freeDNS.sh
"

# TODO think about updates
EXCL_DOCKER+="
nc-update.sh
nc-autoupdate-ncp.sh
"
cp etc/library.sh /usr/local/etc/

source /usr/local/etc/library.sh

# prevent installing some apt packages in the docker version
[[ "$DOCKERBUILD" == 1 ]] && {
  mkdir -p $CONFDIR
  for opt in $EXCL_DOCKER; do 
    touch $CONFDIR/$opt
done
}

# copy all files in bin and etc
for file in bin/* etc/*; do
  [ -f "$file" ] || continue;
  cp "$file" /usr/local/"$file"
done

# install new entries of nextcloudpi-config and update others
for file in etc/nextcloudpi-config.d/*; do
  [ -f "$file" ] || continue;    # skip dirs
  [ -f /usr/local/"$file" ] || { # new entry
    install_script "$file"       # install

    # configure if active by default
    grep -q '^ACTIVE_=yes$' "$file" && activate_script "$file" 
  }

  # save current configuration to (possibly) updated script
  [ -f /usr/local/"$file" ] && {
    VARS=( $( grep "^[[:alpha:]]\+_=" /usr/local/"$file" | cut -d= -f1 ) )
    VALS=( $( grep "^[[:alpha:]]\+_=" /usr/local/"$file" | cut -d= -f2 ) )
    for i in $( seq 0 1 ${#VARS[@]} ); do
      sed -i "s|^${VARS[$i]}=.*|${VARS[$i]}=${VALS[$i]}|" "$file"
    done
  }

  cp "$file" /usr/local/"$file"
done

# these files can contain sensitive information, such as passwords
chown -R root:www-data /usr/local/etc/nextcloudpi-config.d
chmod 660 /usr/local/etc/nextcloudpi-config.d/*

# install web interface
cp -r ncp-web /var/www/
chown -R www-data:www-data /var/www/ncp-web
chmod 770                  /var/www/ncp-web

# remove unwanted packages for the docker version
[[ "$DOCKERBUILD" == 1 ]] && {
  for opt in $EXCL_DOCKER; do 
    rm $CONFDIR/$opt
done
}

## BACKWARD FIXES ( for older images )

[[ "$DOCKERBUILD" != 1 ]] && {

# ncp-web password auth
    CERTFILE=$( grep SSLCertificateFile    /etc/apache2/sites-available/ncp.conf| awk '{ print $2 }' )
    KEYFILE=$(  grep SSLCertificateKeyFile /etc/apache2/sites-available/ncp.conf| awk '{ print $2 }' )

  grep -q DefineExternalAuth /etc/apache2/sites-available/ncp.conf || {
    apt-get update
    apt-get install -y --no-install-recommends libapache2-mod-authnz-external pwauth
    a2enmod authnz_external authn_core auth_basic
    bash -c "sleep 2 && systemctl restart apache2" &>/dev/null &
  }

  cat > /etc/apache2/sites-available/ncp.conf <<EOF
Listen 4443
<VirtualHost _default_:4443>
  DocumentRoot /var/www/ncp-web
  SSLEngine on
  SSLCertificateFile    $CERTFILE
  SSLCertificateKeyFile $KEYFILE

  <IfModule mod_authnz_external.c>
    DefineExternalAuth pwauth pipe /usr/sbin/pwauth
  </IfModule>

</VirtualHost>
<Directory /var/www/ncp-web/>

  AuthType Basic
  AuthName "ncp-web login"
  AuthBasicProvider external
  AuthExternal pwauth

  SetEnvIf Request_URI "^" noauth
  SetEnvIf Request_URI "^index\\.php$" !noauth
  SetEnvIf Request_URI "^/$" !noauth
  SetEnvIf Request_URI "^/wizard/index.php$" !noauth
  SetEnvIf Request_URI "^/wizard/$" !noauth

  <RequireAll>

   <RequireAny>
      Require host localhost
      Require local
      Require ip 192.168
      Require ip 10
   </RequireAny>

   <RequireAny>
      Require env noauth
      Require user pi
   </RequireAny>

  </RequireAll>

</Directory>
EOF

  # temporary workaround for bug https://github.com/certbot/certbot/issues/5138#issuecomment-333391771
    cat > /etc/pip.conf <<EOF
[global]
extra-index-url=https://www.piwheels.hostedpi.com/simple
extra-index-url=https://www.piwheels.hostedpi.com/simple/zope.components
EOF
  test -e /etc/pip.conf && grep -q zope /etc/pip.conf || { 
    /etc/letsencrypt/letsencrypt-auto --help
  }

  # tweak fail2ban email 
  F=/etc/fail2ban/action.d/sendmail-common.conf
  sed -i 's|Fail2Ban|NextCloudPi|' /etc/fail2ban/action.d/sendmail-whois-lines.conf
  grep -q actionstart_ "$F" || sed -i 's|actionstart|actionstart_|' "$F"
  grep -q actionstop_  "$F" || sed -i 's|actionstop|actionstop_|'   "$F"
  type whois &>/dev/null || { apt-get update; apt-get install --no-install-recommends -y whois; }
  
  # fix notify unattended upgrades repeating lines
  cat > /usr/local/bin/ncp-notify-unattended-upgrade <<EOF
#!/bin/bash
LOGFILE=/var/log/unattended-upgrades/unattended-upgrades.log
STAMPFILE=/var/run/.ncp-notify-unattended-upgrades
VERFILE=/usr/local/etc/ncp-version

test -e "\$LOGFILE" || { echo "\$LOGFILE not found"; exit 1; }

test -e "\$STAMPFILE" || touch "\$STAMPFILE"

[ \$( date -r "\$LOGFILE" +'%y%m%d%H%M' ) -le \$( date -r "\$STAMPFILE" +'%y%m%d%H%M' ) ] && { echo "info is up to date"; exit 0; }

LINE=\$( grep "INFO Packages that will be upgraded" "\$LOGFILE" | tail -1 )

[[ "\$LINE" == "" ]] && { echo "no new upgrades"; touch "\$STAMPFILE"; exit 0; }

PKGS=\$( sed 's|^.*Packages that will be upgraded: ||' <<< "\$LINE" )

echo "Packages automatically upgraded: \$PKGS"

touch "\$STAMPFILE"

sudo -u www-data php /var/www/nextcloud/occ notification:generate \
  $USER_ "NextCloudPi Unattended Upgrades" \
     -l "Packages automatically upgraded \$PKGS"
EOF
  chmod +x /usr/local/bin/ncp-notify-unattended-upgrade
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

