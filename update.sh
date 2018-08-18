#!/bin/bash

# Updater for NextCloudPi
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at https://ownyourbits.com/
#

CONFDIR=/usr/local/etc/ncp-config.d/

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
UFW.sh
nc-snapshot.sh
nc-snapshot-auto.sh
nc-audit.sh
SSH.sh
fail2ban.sh
NFS.sh
"

# better use a designated container
EXCL_DOCKER+="
samba.sh
"

# check running apt
pgrep apt &>/dev/null && { echo "apt is currently running. Try again later";  exit 1; }

cp etc/library.sh /usr/local/etc/

source /usr/local/etc/library.sh

mkdir -p "$CONFDIR"

# prevent installing some apt packages in the docker version
[[ -f /.docker-image ]] && {
  for opt in $EXCL_DOCKER; do 
    touch $CONFDIR/$opt
done
}

# copy all files in bin and etc
for file in bin/* etc/*; do
  [ -f "$file" ] || continue;
  cp "$file" /usr/local/"$file"
done

# install new entries of ncp-config and update others
for file in etc/ncp-config.d/*; do
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

# install localization files
cp -rT etc/ncp-config.d/l10n "$CONFDIR"/l10n

# these files can contain sensitive information, such as passwords
chown -R root:www-data "$CONFDIR"
chmod 660 "$CONFDIR"/*
chmod 750 "$CONFDIR"/l10n

# install web interface
cp -r ncp-web /var/www/
chown -R www-data:www-data /var/www/ncp-web
chmod 770                  /var/www/ncp-web

[[ -f /.docker-image ]] && {
  # remove unwanted packages for the docker version
  for opt in $EXCL_DOCKER; do rm $CONFDIR/$opt; done

  # update services
  cp docker-common/{lamp/010lamp,nextcloud/020nextcloud,nextcloudpi/000ncp} /etc/services-available.d

}

## BACKWARD FIXES ( for older images )

# not for image builds, only live updates
[[ ! -f /.ncp-image ]] && {

  # docker images only
  [[ -f /.docker-image ]] && {
    # install curl for dynDNS and duckDNS
    [[ -f /usr/bin/curl ]] || {
      apt-get update
      apt-get install -y --no-install-recommends curl
    }
  }

  # for non docker images
  [[ ! -f /.docker-image ]] && {
    :
  }

  # fix update httpd log location in virtual host after nc-datadir
  sed -i "s|CustomLog.*|CustomLog /var/log/apache2/nc-access.log combined|" /etc/apache2/sites-available/nextcloud.conf
  sed -i "s|ErrorLog .*|ErrorLog  /var/log/apache2/nc-error.log|"           /etc/apache2/sites-available/nextcloud.conf

  # fix systemd timer still present
  [[ -f /etc/systemd/system/nc-scan.service ]] && {
    systemctl stop nc-scan.service
    systemctl disable nc-scan.service
    rm -f /etc/systemd/system/nc-scan.service
    F="$CONFDIR"/nc-scan-auto.sh
    grep -q '^ACTIVE_=yes$' "$F" && {
      cd "$CONFDIR" &>/dev/null
      activate_script nc-scan-auto.sh
      cd -          &>/dev/null
    }
  }
  [[ -f /etc/systemd/system/nc-scan.timer ]] && {
    systemctl stop nc-scan.timer
    systemctl disable nc-scan.timer
    rm -f /etc/systemd/system/nc-scan.timer
  }
  [[ -f /etc/systemd/system/nc-backup.service ]] && {
    systemctl stop nc-backup
    systemctl disable nc-backup
    rm -f /etc/systemd/system/nc-backup.service
    F="$CONFDIR"/nc-backup-auto.sh
    grep -q '^ACTIVE_=yes$' "$F" && {
      cd "$CONFDIR" &>/dev/null
      activate_script nc-backup-auto.sh
      cd -          &>/dev/null
    }
  }
  [[ -f /etc/systemd/system/freedns.service ]] && {
    systemctl stop freedns
    systemctl disable freedns
    rm -f /etc/systemd/system/freedns.service
    F="$CONFDIR"/freeDNS.sh
    grep -q '^ACTIVE_=yes$' "$F" && {
      cd "$CONFDIR" &>/dev/null
      activate_script freeDNS.sh
      cd -          &>/dev/null
    }
  }
  [[ -f /etc/systemd/system/nc-notify-updates.service ]] && {
    systemctl stop nc-notify-updates
    systemctl disable nc-notify-updates
    rm -f /etc/systemd/system/nc-notify-updates.service
    F="$CONFDIR"/nc-notify-updates.sh
    grep -q '^ACTIVE_=yes$' "$F" && {
      cd "$CONFDIR" &>/dev/null
      activate_script nc-notify-updates.sh
      cd -          &>/dev/null
    }
  }
  [[ -f /etc/systemd/system/nc-notify-updates.timer ]] && {
    systemctl stop nc-notify-updates.timer
    systemctl disable nc-notify-updates.timer
    rm -f /etc/systemd/system/nc-notify-updates.timer
  }

  # Update files after re-renaming to NCPi
  # for non docker images
  [[ ! -f /.docker-image ]] && {
  sed -i 's|NextCloudPlus automatically|NextCloudPi automatically|' /etc/samba/smb.conf
  sed -i 's|NextCloudPlus autogenerated|NextCloudPi autogenerated|' /etc/dhcpcd.conf &>/dev/null
  sed -i 's|NextCloudPlus|NextCloudPi|' /etc/fail2ban/action.d/sendmail-whois-lines.conf
  }

  # for non docker images
  [[ ! -f /.docker-image ]] && {
  # make sure provisioning is enabled
  systemctl -q is-enabled nc-provisioning || {
    systemctl start nc-provisioning
    systemctl enable nc-provisioning
  }
  }

  # fix NFS dependency with automount
  [[ -f /lib/systemd/system/nfs-server.service ]] && {
  rm -f /etc/systemd/system/rpcbind.service /etc/systemd/system/nfs-common.services
  sed -i 's|^ExecStartPre=.*|ExecStartPre=/bin/bash -c "/bin/sleep 30; /usr/sbin/exportfs -r"|' /lib/systemd/system/nfs-server.service
  }

  # add the ncc shortcut
  cat > /usr/local/bin/ncc <<'EOF'
#!/bin/bash
sudo -u www-data php /var/www/nextcloud/occ "$@"
EOF
  chmod +x /usr/local/bin/ncc

  # update nc-restore
  cd "$CONFDIR" &>/dev/null
  install_script nc-restore.sh
  cd -          &>/dev/null

  # Update btrfs-sync and btrfs-snap
  wget -q https://raw.githubusercontent.com/nachoparker/btrfs-sync/master/btrfs-sync -O /usr/local/bin/btrfs-sync
  chmod +x /usr/local/bin/btrfs-sync
  wget -q https://raw.githubusercontent.com/nachoparker/btrfs-snp/master/btrfs-snp -O /usr/local/bin/btrfs-snp
  chmod +x /usr/local/bin/btrfs-snp

  # update to NC13.0.4
  F="$CONFDIR"/nc-autoupdate-nc.sh
  grep -q '^ACTIVE_=yes$' "$F" && {
    cd "$CONFDIR" &>/dev/null
    activate_script nc-autoupdate-nc.sh
    cd -          &>/dev/null
  }

  # change letsencrypt from git to package based
  [[ -f /usr/bin/letsencrypt ]] || {
    echo "updating letsencrypt..."
    apt-get update
    apt-get install -y --no-install-recommends letsencrypt
  }

  # fix nextcloud-domain running before default GW is ready
  pkill -f nextcloud-domain
  cat > /usr/local/bin/nextcloud-domain.sh <<'EOF'
#!/bin/bash
# wicd service finishes before completing DHCP
while :; do
  IFACE="$( ip r | grep "default via" | awk '{ print $5 }' | head -1 )"
  IP="$( ip a show dev "$IFACE" | grep global | grep -oP '\d{1,3}(.\d{1,3}){3}' | head -1 )"
  [[ "$IP" != "" ]] && break
  sleep 3
done
cd /var/www/nextcloud
sudo -u www-data php occ config:system:set trusted_domains 1 --value=$IP
EOF

    # letsencrypt: notify of renewals
    [[ -f /etc/cron.weekly/letsencrypt-ncp ]] && ! grep -q SSL /etc/cron.weekly/letsencrypt-ncp && {
      NCDIR=/var/www/nextcloud
      OCC="$NCDIR"/occ
      NOTIFYUSER_=ncp
      cat > /etc/cron.weekly/letsencrypt-ncp <<EOF
#!/bin/bash

# renew and notify
/usr/bin/certbot renew --quiet --renew-hook '
  sudo -u www-data php $OCC notification:generate \
                            $NOTIFYUSER_ "SSL renewal" \
                            -l "Your SSL certificate(s) \$RENEWED_DOMAINS has been renewed for another 90 days"
  '

# notify if fails
[[ \$? -ne 0 ]] && sudo -u www-data php $OCC notification:generate \
                                             $NOTIFYUSER_ "SSL renewal error" \
                                             -l "SSL certificate renewal failed. See /var/log/letsencrypt/letsencrypt.log"

# cleanup
rm -rf $NCDIR/.well-known
EOF
      chmod +x /etc/cron.weekly/letsencrypt-ncp
    }

  # update nc-backup
  cd "$CONFDIR" &>/dev/null
  install_script nc-backup.sh
  cd -          &>/dev/null

  # remove redundant opcache configuration. Leave until update bug is fixed -> https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=815968
  [[ "$( ls -l /etc/php/7.0/fpm/conf.d/*-opcache.ini |  wc -l )" -gt 1 ]] && rm "$( ls /etc/php/7.0/fpm/conf.d/*-opcache.ini | tail -1 )"
  [[ "$( ls -l /etc/php/7.0/cli/conf.d/*-opcache.ini |  wc -l )" -gt 1 ]] && rm "$( ls /etc/php/7.0/cli/conf.d/*-opcache.ini | tail -1 )"

} # end - only live updates

exit 0

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

