#!/bin/bash

# NextcloudPi additions to Raspbian
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at https://nextcloudpi.com
#

WEBADMIN=ncp
WEBPASSWD=ownyourbits
BRANCH="${BRANCH:-master}"

BINDIR=/usr/local/bin/ncp
CONFDIR=/usr/local/etc/ncp-config.d/
APTINSTALL="apt-get install -y --no-install-recommends"
export DEBIAN_FRONTEND=noninteractive


install()
{
  # NCP-CONFIG
  apt-get update
  $APTINSTALL git dialog whiptail jq file lsb-release tmux
  mkdir -p "$CONFDIR" "$BINDIR"

  # This has changed, pi user no longer exists by default, the user needs to create it with Raspberry Pi imager
  # The raspi-config layout and options have also changed
  # https://github.com/RPi-Distro/raspi-config/blob/master/raspi-config
  test -f /usr/bin/raspi-config && {
    # shellcheck disable=SC1003
    sed -i '/S3 Password/i "S0 NextcloudPi Configuration" "Configuration of NextcloudPi" \\' /usr/bin/raspi-config
    sed -i '/S3\\ \*) do_change_pass ;;/i S0\\ *) ncp-config ;;'                             /usr/bin/raspi-config
  }

  # add the ncc shortcut
  cat > /usr/local/bin/ncc <<'EOF'
#!/bin/bash
[[ ${EUID} -eq 0 ]] && SUDO="sudo -E -u www-data"
${SUDO} php /var/www/nextcloud/occ "$@"
EOF
  chmod +x /usr/local/bin/ncc

  # NCP-WEB

  ## VIRTUAL HOST
  cat > /etc/apache2/sites-available/ncp-activation.conf <<EOF
<VirtualHost _default_:443>
  DocumentRoot /var/www/ncp-web/
  SSLEngine on
  SSLCertificateFile      /etc/ssl/certs/ssl-cert-snakeoil.pem
  SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key

</VirtualHost>
<Directory /var/www/ncp-web/>
  <RequireAll>

   <RequireAny>
      Require host localhost
      Require local
      Require ip 192.168
      Require ip 172
      Require ip 10
      Require ip fe80::/10
      Require ip fd00::/8
   </RequireAny>

  </RequireAll>
</Directory>
EOF

  install_template apache2/ncp.conf.sh /etc/apache2/sites-available/ncp.conf --defaults

  $APTINSTALL libapache2-mod-authnz-external pwauth
  a2enmod authnz_external authn_core auth_basic
  a2dissite 001-nextcloud
  a2ensite ncp-activation

  ## NCP USER FOR AUTHENTICATION
  id -u "$WEBADMIN" &>/dev/null || useradd --home-dir /nonexistent "$WEBADMIN"
  echo -e "$WEBPASSWD\n$WEBPASSWD" | passwd "$WEBADMIN"
  is_docker || is_lxc || {
    chsh -s /usr/sbin/nologin "$WEBADMIN"
    passwd -l root
  }

  ## NCP LAUNCHER
  mkdir -p /home/www
  chown www-data:www-data /home/www
  chmod 700 /home/www

  cat > /home/www/ncp-launcher.sh <<'EOF'
#!/bin/bash
grep -q '[\\&#;`|*?~<>^()[{}$&[:space:]]' <<< "$*" && exit 1
source /usr/local/etc/library.sh
run_app $1
EOF
  chmod 700 /home/www/ncp-launcher.sh

  cat > /home/www/ncp-backup-launcher.sh <<'EOF'
#!/bin/bash
action="${1}"
file="${2}"
compressed="${3}"
grep -q '[\\&#;`|*?~<>^()[{}$&]' <<< "$*" && exit 1
[[ "$file" =~ ".." ]] && exit 1
[[ "${action}" == "chksnp" ]] && {
  btrfs subvolume show "$file" &>/dev/null || exit 1
  exit
}
[[ "${action}" == "delsnp" ]] && {
  btrfs subvolume delete "$file" || exit 1
  exit
}
[[ -f "$file" ]] || exit 1
[[ "$file" =~ ".tar" ]] || exit 1
[[ "${action}" == "del" ]] && {
  [[ "$(file "$file")" =~ "tar archive" ]] || [[ "$(file "$file")" =~ "gzip compressed data" ]] || exit 1
  rm "$file" || exit 1
  exit
}
[[ "$compressed" != "" ]] && pigz="-I pigz"
tar $pigz -tf "$file" data &>/dev/null
EOF
  chmod 700 /home/www/ncp-backup-launcher.sh

  cat > /home/www/ncp-app-bridge.sh <<'EOF'
#!/bin/bash
set -e
grep -q '[\\&#;`|*?~<>^()[{}$&]' <<< "$*" && exit 1
action="${1?}"
[[ "$action" == "config" ]] && {
  config_type="${2?}"
  arg="${3}"

  [[ -z "$arg" ]] || {
    key="${arg%=*}"
    val="${arg#*=}"
  }

  if [[ "$config_type" == "ncp" ]]
  then
    config_path="/usr/local/etc/ncp.cfg"
  elif [[ "$config_type" == "ncp-community" ]]
  then
    . /usr/local/etc/library.sh
    [[ -z "${key}" ]] || {
      set_app_param ncp-community.sh "${key}" "${val}"
    }
    get_app_params ncp-community.sh
    exit $?
  else
    echo "ERROR: Invalid config name '${config_type}'" >&2
    exit 1
  fi

  [[ -z "${key}" ]] || {
    cfg="$(jq ".${key} = \"${val}\"" <"$config_path")"
    echo "$cfg" > "$config_path"
  }
  cat "$config_path"
  exit 0
}

[[ "$action" == "file" ]] && {
  file="${2?}"
  if [[ "$file" == "ncp-version" ]]
  then
    cat /usr/local/etc/ncp-version
  else
    echo "ERROR: Invalid file '${file}'" >&2
    exit 1
  fi
  exit 0
}
EOF
  chmod 700 /home/www/ncp-app-bridge.sh
  echo "www-data ALL = NOPASSWD: /home/www/ncp-launcher.sh , /home/www/ncp-backup-launcher.sh, /home/www/ncp-app-bridge.sh, /sbin/halt, /sbin/reboot" >> /etc/sudoers

  # NCP AUTO TRUSTED DOMAIN
  mkdir -p /usr/lib/systemd/system
  cat > /usr/lib/systemd/system/nextcloud-domain.service <<'EOF'
[Unit]
Description=Register Current IP as Nextcloud trusted domain
Requires=network.target
After=mysql.service redis.service

[Service]
ExecStart=/bin/bash /usr/local/bin/nextcloud-domain.sh
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

  [[ "$DOCKERBUILD" != 1 ]] && systemctl enable nextcloud-domain

  # NEXTCLOUDPI UPDATES
  cat > /etc/cron.daily/ncp-check-version <<EOF
#!/bin/sh
/usr/local/bin/ncp-check-version
EOF
  chmod a+x /etc/cron.daily/ncp-check-version
  touch               /var/run/.ncp-latest-version
  chown root:www-data /var/run/.ncp-latest-version
  chmod g+w           /var/run/.ncp-latest-version

  # Install all ncp-apps
  ALLOW_UPDATE_SCRIPT=1 bin/ncp-update "$BRANCH" || exit $?

  # LIMIT LOG SIZE
  grep -q maxsize /etc/logrotate.d/apache2 || sed -i /weekly/amaxsize2M /etc/logrotate.d/apache2
  cat > /etc/logrotate.d/ncp <<'EOF'
/var/log/ncp.log
{
        rotate 4
        size 500K
        missingok
        notifempty
        compress
}
EOF
  chmod 0444 /etc/logrotate.d/ncp

  # ONLY FOR IMAGE BUILDS
  if [[ -f /.ncp-image ]]; then
    rm -rf /var/log/ncp.log

    ## NEXTCLOUDPI MOTD
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

    echo '
NCP is not activated yet. Please enter https://nextcloudpi.local or this instance'"'"'s local IP address in your webbrowser to complete activation. You can find detailed instructions at https://nextcloudpi.com/activate
' >> /etc/issue
    chmod a+x /etc/update-motd.d/*

    ## HOSTNAME AND mDNS
    [[ -f /.docker-image ]] || {
      $APTINSTALL avahi-daemon
      sed -i '/^127.0.1.1/d'           /etc/hosts
      sed -i "\$a127.0.1.1 nextcloudpi $(hostname)" /etc/hosts
    }
    echo nextcloudpi > /etc/hostname

    ## tag image
    is_docker && local DOCKER_TAG="_docker"
    is_lxc && local DOCKER_TAG="_lxc"
    echo "NextcloudPi${DOCKER_TAG}_$( date  "+%m-%d-%y" )" > /usr/local/etc/ncp-baseimage

    ## SSH hardening
    if [[ -f /etc/ssh/sshd_config ]]; then
      sed -i 's|^#AllowTcpForwarding .*|AllowTcpForwarding no|'     /etc/ssh/sshd_config
      sed -i 's|^#ClientAliveCountMax .*|ClientAliveCountMax 2|'    /etc/ssh/sshd_config
      sed -i 's|^MaxAuthTries .*|MaxAuthTries 1|'                   /etc/ssh/sshd_config
      sed -i 's|^#MaxSessions .*|MaxSessions 2|'                    /etc/ssh/sshd_config
      sed -i 's|^#TCPKeepAlive .*|TCPKeepAlive no|'                 /etc/ssh/sshd_config
      sed -i 's|^X11Forwarding .*|X11Forwarding no|'                /etc/ssh/sshd_config
      sed -i 's|^#LogLevel .*|LogLevel VERBOSE|'                    /etc/ssh/sshd_config
      sed -i 's|^#Compression .*|Compression no|'                   /etc/ssh/sshd_config
      sed -i 's|^#AllowAgentForwarding .*|AllowAgentForwarding no|' /etc/ssh/sshd_config
    fi

    ## kernel hardening
    cat >> /etc/sysctl.conf <<EOF
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

    ## other tweaks
    sed -i "s|^UMASK.*|UMASK           027|" /etc/login.defs
  fi
}

configure() { :; }


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
