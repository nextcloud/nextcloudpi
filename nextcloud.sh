#!/bin/bash

# Nextcloud installation on Raspbian over LAMP base
# Tested with 2017-03-02-raspbian-jessie-lite.img
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh nextcloud.sh <IP> (<img>)
#
# See installer.sh instructions for details
#
# More at https://ownyourbits.com/2017/02/13/nextcloud-ready-raspberry-pi-image/
#

VER=11.0.3
ADMINUSER_=admin
DBADMIN_=ncadmin
DBPASSWD_=ownyourbits
MAXFILESIZE_=768M
MAXTRANSFERTIME_=3600
OPCACHEDIR=/var/www/nextcloud/data/.opcache

install()
{
  cd /var/www/
  wget https://download.nextcloud.com/server/releases/nextcloud-$VER.tar.bz2 -O nextcloud.tar.bz2
  tar -xvf nextcloud.tar.bz2
  rm nextcloud.tar.bz2

  ocpath='/var/www/nextcloud'
  htuser='www-data'
  htgroup='www-data'
  rootuser='root'

  printf "Creating possible missing Directories\n"
  mkdir -p $ocpath/data
  mkdir -p $ocpath/updater
  mkdir -p $OPCACHEDIR

  printf "chmod Files and Directories\n"
  find ${ocpath}/ -type f -print0 | xargs -0 chmod 0640
  find ${ocpath}/ -type d -print0 | xargs -0 chmod 0750

  printf "chown Directories\n"
  # recommended defaults do not play well with updater app
  # re-check this with every new version
  #chown -R ${rootuser}:${htgroup} ${ocpath}/
  chown -R ${htuser}:${htgroup} ${ocpath}/
  chown -R ${htuser}:${htgroup} ${ocpath}/apps/
  chown -R ${htuser}:${htgroup} ${ocpath}/config/
  chown -R ${htuser}:${htgroup} ${ocpath}/data/
  chown -R ${htuser}:${htgroup} ${ocpath}/themes/
  chown -R ${htuser}:${htgroup} ${ocpath}/updater/
  chown -R ${htuser}:${htgroup} $OPCACHEDIR

  chmod +x ${ocpath}/occ

  printf "chmod/chown .htaccess\n"
  if [ -f ${ocpath}/.htaccess ]; then
    # breaks updater, see above
    #chmod 0644 ${ocpath}/.htaccess
    chmod 0664 ${ocpath}/.htaccess
    chown ${rootuser}:${htgroup} ${ocpath}/.htaccess
  fi
  if [ -f ${ocpath}/data/.htaccess ]; then
    chmod 0644 ${ocpath}/data/.htaccess
    chown ${rootuser}:${htgroup} ${ocpath}/data/.htaccess
  fi

cat > /etc/apache2/sites-available/000-default.conf <<'EOF'
<VirtualHost _default_:80>
  DocumentRoot /var/www/nextcloud
  <IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteCond %{HTTPS} !=on
    RewriteRule ^/?(.*) https://%{SERVER_NAME}/$1 [R,L]
  </IfModule>
</VirtualHost>
EOF

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
  systemctl enable nextcloud-domain

  cat > /usr/local/bin/nextcloud-domain.sh <<'EOF'
#!/bin/bash
IFACE=$( ip r | grep "default via" | awk '{ print $5 }' )
IP=$( ip a | grep "global $IFACE" | grep -oP '\d{1,3}(.\d{1,3}){3}' | head -1 )
cd /var/www/nextcloud
sudo -u www-data php occ config:system:set trusted_domains 1 --value=$IP
EOF
}

configure()
{
  cd /var/www/nextcloud/

  sudo -u www-data php occ maintenance:install --database \
  "mysql" --database-name "nextcloud"  --database-user "$DBADMIN_" --database-pass \
  "$DBPASSWD_" --admin-user "$ADMINUSER_" --admin-pass "$DBPASSWD_" 

  sudo -u www-data php occ background:cron

  sed -i '$s|^.*$|  '\''memcache.local'\'' => '\''\\\\OC\\\\Memcache\\\\APCu'\'',\\n);|' /var/www/nextcloud/config/config.php

  sed -i "s/post_max_size=.*/post_max_size=$MAXFILESIZE_/"             /var/www/nextcloud/.user.ini 
  sed -i "s/upload_max_filesize=.*/upload_max_filesize=$MAXFILESIZE_/" /var/www/nextcloud/.user.ini 
  sed -i "s/memory_limit=.*/memory_limit=$MAXFILESIZE_/"               /var/www/nextcloud/.user.ini 

  # slow transfers will be killed after this time
  cat >> /var/www/nextcloud/.user.ini <<< "max_execution_time=$MAXTRANSFERTIME_"

  echo "*/15  *  *  *  * php -f /var/www/nextcloud/cron.php" > /tmp/crontab_http
  crontab -u www-data /tmp/crontab_http
  rm /tmp/crontab_http
}

cleanup()   
{ 
  [ "$STATE" != "1" ] && return
  apt-get autoremove
  apt-get clean
  rm /var/lib/apt/lists/* -r
  rm -f /home/pi/.bash_history

  systemctl disable ssh
  nohup halt &>/dev/null &
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

