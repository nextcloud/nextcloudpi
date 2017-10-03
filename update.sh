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

[[ "$DOCKERBUILD" != 1 ]] && {
  # fix automount, reinstall if its old version
  AMFILE=/usr/local/etc/nextcloudpi-config.d/nc-automount.sh
  test -e $AMFILE && { grep -q inotify-tools $AMFILE || rm $AMFILE; }

  # fix modsecurity, reinstall if its old verion
  MSFILE=/usr/local/etc/nextcloudpi-config.d/modsecurity.sh
  test -e $MSFILE && { grep -q "NextCloudPi:" $MSFILE  || rm $MSFILE; }
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

# force-fix unattended-upgrades 
cd /usr/local/etc/nextcloudpi-config.d/ || exit 1
activate_script unattended-upgrades.sh

# for old image users, save default password
test -f /root/.my.cnf || echo -e "[client]\npassword=ownyourbits" > /root/.my.cnf

# fix updates from NC12 to NC12.0.1
chown www-data /var/www/nextcloud/.htaccess
rm -rf /var/www/nextcloud/.well-known

# fix permissions for ncp-web: shutdown button
sed -i 's|www-data.*|www-data ALL = NOPASSWD: /home/www/ncp-launcher.sh , /sbin/halt|' /etc/sudoers

# fix fail2ban misconfig in stretch
rm -f /etc/fail2ban/jail.d/defaults-debian.conf

# update ncp-launcher to support realtime updates with SSE
  cat > /home/www/ncp-launcher.sh <<'EOF'
#!/bin/bash
DIR=/usr/local/etc/nextcloudpi-config.d
test -f $DIR/$1 || { echo "File not found"; exit 1; }
source /usr/local/etc/library.sh
cd $DIR
touch /run/ncp.log
chmod 640 /run/ncp.log
chown root:www-data /run/ncp.log
launch_script $1 &> /run/ncp.log
EOF
  chmod 700 /home/www/ncp-launcher.sh

# update notify-updates to also notify about unattended upgrades
cat > /etc/systemd/system/nc-notify-updates.service <<EOF
[Unit]
Description=Notify in NC when a NextCloudPi update is available

[Service]
Type=simple
ExecStart=/usr/local/bin/ncp-notify-update
ExecStartPost=/usr/local/bin/ncp-notify-unattended-upgrade

[Install]
WantedBy=default.target
EOF

  # adjust max PHP processes so Apps don't overload the board (#146)
  sed -i 's|pm.max_children =.*|pm.max_children = 3|' /etc/php/7.0/fpm/pool.d/www.conf

  # automount remove old fstab lines
  sed -i '/\/dev\/USBdrive/d' /etc/fstab
  rm -f /etc/udev/rules.d/50-automount.rules /usr/local/etc/blknum
  udevadm control --reload-rules

  # remove default config file in stretch
  rm -f /etc/apt/apt.conf.d/20auto-upgrades

  # disable SMB1 and SMB2
  grep -q SMB3 /etc/samba/smb.conf || sed -i '/\[global\]/aprotocol = SMB3' /etc/samba/smb.conf

  # improvements to automount-links
  cat > /usr/local/etc/nc-automount-links-mon <<'EOF'
#!/bin/bash
inotifywait --monitor --event create --event delete --format '%f %e' /media/ | \
  grep --line-buffered ISDIR | while read f; do
    echo $f
    sleep 0.5
    /usr/local/etc/nc-automount-links
done
EOF
  chmod +x /usr/local/etc/nc-automount-links-mon

  # install and configure email if not present
  type sendmail &>/dev/null || {
    echo "Installing and configuring email"
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends postfix
    OCC=/var/www/nextcloud/occ
    sudo -u www-data php $OCC config:system:set mail_smtpmode     --value="php"
    sudo -u www-data php $OCC config:system:set mail_smtpauthtype --value="LOGIN"
    sudo -u www-data php $OCC config:system:set mail_from_address --value="admin"
    sudo -u www-data php $OCC config:system:set mail_domain       --value="ownyourbits.com"
}

# images are now tagged
test -f /usr/local/etc/ncp-baseimage || echo "untagged" > /usr/local/etc/ncp-baseimage

# remove artifacts
rm -f /usr/local/etc/nextcloudpi-config.d/config_.txt

# ncp-web password auth
  grep -q DefineExternalAuth /etc/apache2/sites-available/ncp.conf || {
    CERTFILE=$( grep SSLCertificateFile    /etc/apache2/sites-available/ncp.conf| awk '{ print $2 }' )
    KEYFILE=$(  grep SSLCertificateKeyFile /etc/apache2/sites-available/ncp.conf| awk '{ print $2 }' )
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

  <RequireAll>

   <RequireAny>
      Require host localhost
      Require local
      Require ip 192.168
      Require ip 10
   </RequireAny>

   Require user pi

  </RequireAll>

</Directory>
EOF
    apt-get update
    apt-get install -y --no-install-recommends libapache2-mod-authnz-external pwauth
    a2enmod authnz_external authn_core auth_basic
    bash -c "sleep 2 && systemctl restart apache2" &>/dev/null &
  }

  # temporary workaround for bug https://github.com/certbot/certbot/issues/5138#issuecomment-333391771
  test -e /etc/pip.conf && grep -q zope /etc/pip.conf || { 
    cat >> /etc/pip.conf <<<"extra-index-url=https://www.piwheels.hostedpi.com/simple/zope.components"
    /etc/letsencrypt/letsencrypt-auto --help
  }
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

