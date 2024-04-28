#!/bin/bash

set -eu -o pipefail

new_cfg=/usr/local/etc/ncp-recommended.cfg
[[ -f "${new_cfg}" ]] || { echo "Already on the lastest recommended distribution. Abort." >&2; exit 1; }

echo "
>>> ATTENTION <<<
This is a dangerous process that is only guaranteed to work properly if you
have not made manual changes in the system. Backup the SD card first and
proceed at your own risk.

Note that this is not a requirement for NCP to continue working properly.
The current distribution will keep receiving updates for some time.

Do you want to continue? [y/N]"

if [[ "${DEBIAN_FRONTEND:-}" == "noninteractive" ]] || ! [[ -t 0 ]]
then
  echo "Noninteractive environment detected. Automatically proceeding in 30 seconds..."
  sleep 30
else
  read -n1 -r key
  [[ "${key,,}" == y ]] || exit 0
fi

export DEBIAN_FRONTEND=noninteractive

source /usr/local/etc/library.sh
is_more_recent_than "${PHPVER}.0" "8.0.0" || {
  echo "You still have PHP version ${PHPVER} installed. Please update to the latest supported version of nextcloud (which will also update your PHP version) before proceeding with the distribution upgrade."
  echo "Exiting."
  exit 1
}
save_maintenance_mode

# Perform dist-upgrade

apt-get update && apt-get upgrade -y
for aptlist in /etc/apt/sources.list /etc/apt/sources.list.d/php.list /etc/apt/sources.list.d/armbian.list
do
  [ -f "$aptlist" ] && sed -i -e "s/bullseye/bookworm/g" "$aptlist"
done
for aptlist in /etc/apt/sources.list.d/*.list
do
	[[ "$aptlist" =~ "/etc/apt/sources.list.d/"(php|armbian)".list" ]] || continue
    echo "Disabling repositories from \"$aptlist\""
    sed -i -e "s/deb/#deb/g" "$aptlist"
done
apt-get update && apt-get upgrade -y --without-new-pkgs
if is_lxc
then
  # Required to avoid breakage of /etc/resolv.conf
  apt-get install -y --no-install-recommends systemd-resolved && systemctl enable --now systemd-resolved
fi
apt-get full-upgrade -y
sudo apt-get --purge  autoremove -y

apt-get install -y --no-install-recommends exfatprogs

#mkdir -p /etc/systemd/system/php8.1-fpm.service.d
#echo '[Service]' > /etc/systemd/system/php8.1-fpm.service.d/ncp.conf
#echo 'ExecStartPre=mkdir -p /var/run/php' >> /etc/systemd/system/php8.1-fpm.service.d/ncp.conf
#[[ "$INIT_SYSTEM" != "systemd" ]] || { systemctl daemon-reload && systemctl restart php8.1-fpm; }

restore_maintenance_mode
cfg="$(jq "." "$NCPCFG")"
cfg="$(jq ".release = \"bookworm\"" <<<"$cfg")"
echo "$cfg" > "$NCPCFG"
rm -f /etc/update-motd.d/30ncp-dist-upgrade

echo "Update to Debian 12 (bookworm) successful."

is_active_app unattended-upgrades && {
  echo "Setting up unattended upgrades..."
  run_app unattended-upgrades || true
  echo "done."
}