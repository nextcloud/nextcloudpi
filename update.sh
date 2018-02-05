#!/bin/bash

# Updater for NextCloudPi
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

# need to be fixed for this
EXCL_DOCKER+="
nc-webui.sh
fail2ban.sh
spDYN.sh
"

# better use a designated container
EXCL_DOCKER+="
samba.sh
NFS.sh
"

# use systemd timers
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

# check running apt
pgrep apt &>/dev/null && { echo "apt is currently running. Try again later";  exit 1; }

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

# not for image builds, only live updates
[[ ! -f /.ncp-image ]] && {

  # fix automount in latest images
   test -f /etc/udev/rules.d/90-qemu.rules && {
     rm -f /etc/udev/rules.d/90-qemu.rules
     udevadm control --reload-rules && udevadm trigger
     pgrep -c udiskie &>/dev/null && systemctl restart nc-automount
   }

   # btrfs tools
   type btrfs &>/dev/null || {
    apt-get update 
    apt-get install -y --no-install-recommends btrfs-tools
  }

  # harden security

  ## harden redis
  REDIS_CONF=/etc/redis/redis.conf
  REDISPASS=$( grep "^requirepass" /etc/redis/redis.conf  | cut -d' ' -f2 )
  [[ "$REDISPASS" == "" ]] && REDISPASS=$( openssl rand -base64 32 )
  sed -i 's|# rename-command CONFIG ""|rename-command CONFIG ""|'  $REDIS_CONF
  sed -i "s|# requirepass .*|requirepass $REDISPASS|"              $REDIS_CONF

  grep -q "'password'" /var/www/nextcloud/config/config.php || \
    sed -i "/timeout/a'password' => '$REDISPASS'," /var/www/nextcloud/config/config.php

  ## harden postfix
  sed -i 's|^smtpd_banner .*|smtpd_banner = $myhostname ESMTP|'    /etc/postfix/main.cf
  sed -i 's|^disable_vrfy_command .*|disable_vrfy_command = yes|'  /etc/postfix/main.cf

  ## harden SSH
  sed -i 's|^#AllowTcpForwarding .*|AllowTcpForwarding no|'     /etc/ssh/sshd_config
  sed -i 's|^#ClientAliveCountMax .*|ClientAliveCountMax 2|'    /etc/ssh/sshd_config
  sed -i 's|^MaxAuthTries .*|MaxAuthTries 1|'                   /etc/ssh/sshd_config
  sed -i 's|^#MaxSessions .*|MaxSessions 2|'                    /etc/ssh/sshd_config
  sed -i 's|^#PermitRootLogin .*|PermitRootLogin no|'           /etc/ssh/sshd_config
  sed -i 's|^#TCPKeepAlive .*|TCPKeepAlive no|'                 /etc/ssh/sshd_config
  sed -i 's|^X11Forwarding .*|X11Forwarding no|'                /etc/ssh/sshd_config
  sed -i 's|^#LogLevel .*|LogLevel VERBOSE|'                    /etc/ssh/sshd_config
  sed -i 's|^#Compression .*|Compression no|'                   /etc/ssh/sshd_config
  sed -i 's|^#AllowAgentForwarding .*|AllowAgentForwarding no|' /etc/ssh/sshd_config

  ## harden kernel
  grep -q protected_hardlinks=1 /etc/sysctl.conf || cat >> /etc/sysctl.conf <<EOF
fs.protected_hardlinks=1
fs.protected_symlinks=1
kernel.core_uses_pid=1
kernel.dmesg_restrict=1
kernel.kptr_restrict=2
kernel.sysrq=0
net.ipv4.conf.all.accept_redirects=0
net.ipv4.conf.all.log_martians=1
net.ipv4.conf.all.rp_filter=1
net.ipv4.conf.all.send_redirects=0
net.ipv4.conf.default.accept_redirects=0
net.ipv4.conf.default.accept_source_route=0
net.ipv4.conf.default.log_martians=1
net.ipv4.tcp_timestamps=0
net.ipv6.conf.all.accept_redirects=0
net.ipv6.conf.default.accept_redirects=0
EOF
  sysctl -p /etc/sysctl.conf &>/dev/null

  # small tweaks
  cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
  chmod go-x /usr/bin/arm-linux-gnueabihf-* &>/dev/null
  sed -i "s|^UMASK.*|UMASK           027|" /etc/login.defs

  # secure mysql
  DBPASSWD=$( grep password /root/.my.cnf | cut -d= -f2 )
    mysql_secure_installation &>/dev/null <<EOF
$DBPASSWD
y
$DBPASSWD
$DBPASSWD
y
y
y
y
EOF

  # update ncp-backup
  cd /usr/local/etc/nextcloudpi-config.d &>/dev/null
  install_script nc-backup.sh
  cd - &>/dev/null

  # update ncp-backup-auto
  cd /usr/local/etc/nextcloudpi-config.d &>/dev/null
  install_script nc-backup-auto.sh
  cd - &>/dev/null

  # refresh nc-backup-auto
  cd /usr/local/etc/nextcloudpi-config.d &>/dev/null
  grep -q '^ACTIVE_=yes$' nc-backup-auto.sh && activate_script nc-backup-auto.sh 
  cd - &>/dev/null

  # restore pip.conf after workaround
  cat > /etc/pip.conf <<EOF
[global]
extra-index-url=https://www.piwheels.hostedpi.com/simple
EOF

  # update cron letsencrypt
  [[ -f /etc/cron.d/letsencrypt-ncp ]] && rm -f /etc/cron.d/letsencrypt-ncp && {
    cat > /etc/cron.weekly/letsencrypt-ncp <<EOF
#!/bin/bash
/etc/letsencrypt/certbot-auto renew --quiet
EOF
    chmod +x /etc/cron.weekly/letsencrypt-ncp
  }

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

