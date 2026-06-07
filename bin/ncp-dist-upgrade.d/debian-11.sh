#!/bin/bash

set -eu -o pipefail

export DEBIAN_FRONTEND=noninteractive

source /usr/local/etc/library.sh
is_more_recent_than "${PHPVER}.0" "8.0.0" || {
  echo "You still have PHP version ${PHPVER} installed. Please update to the latest supported version of nextcloud (which will also update your PHP version) before proceeding with the distribution upgrade."
  echo "Exiting."
  exit 1
}
save_maintenance_mode

# Perform dist-upgrade

apt-get update
apt-get remove -y libc-dev-bin || true
apt-get upgrade -y
for aptlist in /etc/apt/sources.list /etc/apt/sources.list.d/{php.list,armbian.list,raspi.list}
do
  [ -f "$aptlist" ] && sed -i -e "s/bullseye/bookworm/g" "$aptlist"
done
for aptlist in /etc/apt/sources.list.d/*.list
do
	[[ "$aptlist" =~ "/etc/apt/sources.list.d/"(php|armbian|raspi)".list" ]] || {
    echo "Disabling repositories from \"$aptlist\""
    sed -i -e "s/deb/#deb/g" "$aptlist"
  }
done
apt-get update
apt-get upgrade -y dpkg
apt-get upgrade -y --without-new-pkgs
if is_lxc
then
  # Required to avoid breakage of /etc/resolv.conf
  apt-get install -y --no-install-recommends systemd-resolved && systemctl enable --now systemd-resolved
fi
apt-get full-upgrade -y
sudo apt-get install -y --no-install-recommends libc-dev-bin || true
sudo apt-get --purge  autoremove -y

apt-get install -y --no-install-recommends exfatprogs

#mkdir -p /etc/systemd/system/php8.1-fpm.service.d
#echo '[Service]' > /etc/systemd/system/php8.1-fpm.service.d/ncp-ci.conf
#echo 'ExecStartPre=mkdir -p /var/run/php' >> /etc/systemd/system/php8.1-fpm.service.d/ncp-ci.conf
#[[ "$INIT_SYSTEM" != "systemd" ]] || { systemctl daemon-reload && systemctl restart php8.1-fpm; }

restore_maintenance_mode
cfg="$(jq "." "$NCPCFG")"
cfg="$(jq ".release = \"bookworm\"" <<<"$cfg")"
echo "$cfg" > "$NCPCFG"
rm -f /etc/update-motd.d/30ncp-dist-upgrade
rm -f /usr/local/etc/ncp-recommended.cfg

echo "Update to Debian 12 (bookworm) successful."

is_active_app unattended-upgrades && {
  echo "Setting up unattended upgrades..."
  run_app unattended-upgrades || true
  echo "done."
}