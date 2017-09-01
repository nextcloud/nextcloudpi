#!/bin/bash

# NextcloudPi additions to Raspbian 
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh nextcloudpi.sh <IP> (<img>)
#
# See installer.sh instructions for details
#
# More at https://ownyourbits.com/2017/02/13/nextcloud-ready-raspberry-pi-image/
#

CONFDIR=/usr/local/etc/nextcloudpi-config.d/
UPLOADTMPDIR=/var/www/nextcloud/data/tmp
APTINSTALL="apt-get install -y --no-install-recommends"
export DEBIAN_FRONTEND=noninteractive


install()
{
  # NEXTCLOUDPI-CONFIG
  ##########################################
  apt-get update
  $APTINSTALL dialog
  mkdir -p $CONFDIR
  sed -i '/Change User Password/i"0 NextCloudPi Configuration" "Configuration of NextCloudPi" \\\\'  /usr/bin/raspi-config
  sed -i '/1\\\\ \*) do_change_pass ;;/i0\\\\ *) nextcloudpi-config ;;'                              /usr/bin/raspi-config


  # NEXTCLOUDPI-CONFIG WEB
  ##########################################
  cat > /etc/apache2/sites-available/ncp.conf <<'EOF'
Listen 4443
<VirtualHost _default_:4443>
  DocumentRoot /var/www/ncp-web
  SSLEngine on
  SSLCertificateFile      /etc/ssl/certs/ssl-cert-snakeoil.pem
  SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key
</VirtualHost>
<Directory /var/www/ncp-web/>
  Require host localhost
  Require local
  Require ip 192.168
  Require ip 10
</Directory>
EOF
  a2ensite ncp

  mkdir /home/www -p
  chown www-data:www-data /home/www
  chmod 700 /home/www

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
  echo "www-data ALL = NOPASSWD: /home/www/ncp-launcher.sh , /sbin/halt" >> /etc/sudoers

  # NEXTCLOUDPI MOTD
  ##########################################
  rm -rf /etc/update-motd.d
  mkdir /etc/update-motd.d
  rm /etc/motd
  ln -s /var/run/motd /etc/motd

cat > /etc/update-motd.d/10logo <<EOF
#!/bin/sh
echo
cat /usr/local/etc/ncp-ascii.txt
EOF

  cat > /etc/update-motd.d/20updates <<'EOF'
#!/bin/bash
/usr/local/bin/ncp-check-updates
EOF
  chmod a+x /etc/update-motd.d/*

  # NEXTCLOUDPI AUTO TRUSTED DOMAIN
  ##########################################
  mkdir -p /usr/lib/systemd/system
  cat > /usr/lib/systemd/system/nextcloud-domain.service <<'EOF'
[Unit]
Description=Register Current IP as Nextcloud trusted domain
Requires=network.target
After=mysql.service

[Service]
ExecStart=/bin/bash /usr/local/bin/nextcloud-domain.sh

[Install]
WantedBy=multi-user.target
EOF

  cat > /usr/local/bin/nextcloud-domain.sh <<'EOF'
#!/bin/bash
IFACE=$( ip r | grep "default via" | awk '{ print $5 }' )
IP=$( ip a | grep "global $IFACE" | grep -oP '\d{1,3}(\.\d{1,3}){3}' | head -1 )
# wicd service finishes before completing DHCP
while [[ "$IP" == "" ]]; do
  sleep 3
  IP=$( ip a | grep "global $IFACE" | grep -oP '\d{1,3}(\.\d{1,3}){3}' | head -1 )
done
cd /var/www/nextcloud
sudo -u www-data php occ config:system:set trusted_domains 1 --value=$IP
EOF
  systemctl enable nextcloud-domain # make sure this is called on last re-boot

  # NEXTCLOUDPI UPDATES
  ##########################################
  $APTINSTALL git

  cat > /etc/cron.daily/ncp-check-version <<EOF
#!/bin/sh
/usr/local/bin/ncp-check-version
EOF
  chmod a+x /etc/cron.daily/ncp-check-version

  # TMP UPLOAD DIR
  mkdir -p "$UPLOADTMPDIR"
  chown www-data:www-data "$UPLOADTMPDIR"
  sed -i "s|^;\?upload_tmp_dir =.*$|upload_tmp_dir = $UPLOADTMPDIR|" /etc/php/7.0/fpm/php.ini
  sed -i "s|^;\?sys_temp_dir =.*$|sys_temp_dir = $UPLOADTMPDIR|"     /etc/php/7.0/fpm/php.ini

  touch /usr/local/etc/nextcloudpi-config.d/modsecurity.sh # TODO fix after migration to Stretch is done

  # update to latest version from github as part of the build process
  wget https://raw.githubusercontent.com/nextcloud/nextcloudpi/master/bin/ncp-update -O /usr/local/bin/ncp-update
  chmod a+x /usr/local/bin/ncp-update
  /usr/local/bin/ncp-update

  # External requirements for Apps
  $APTINSTALL -o "Dpkg::Options::=--force-confold" php-smbclient 
}

configure() { :; }

cleanup()   
{ 
  apt-get autoremove -y
  apt-get clean
  rm /var/lib/apt/lists/* -r
  rm -f /home/pi/.bash_history

  rm /etc/udev/rules.d/90-qemu.rules

  systemctl disable ssh
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
