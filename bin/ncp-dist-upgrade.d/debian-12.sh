#!/bin/bash

set -eu -o pipefail

new_cfg=/usr/local/etc/ncp-recommended.cfg
[[ -f "${new_cfg}" ]] || { echo "Already on the latest recommended distribution. Abort." >&2; exit 1; }

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
is_more_recent_than "${PHPVER}.0" "8.2.0" || {
  echo "You still have PHP version ${PHPVER} installed. Please update to the latest supported version of nextcloud (which will also update your PHP version) before proceeding with the distribution upgrade."
  echo "Exiting."
  exit 1
}
save_maintenance_mode

# Perform dist-upgrade

apt-get update
apt-get upgrade -y
for aptlist in /etc/apt/sources.list /etc/apt/sources.list.d/{php.list,armbian.list,raspi.list}
do
  [ -f "$aptlist" ] && sed -i -e "s/bookworm/trixie/g" "$aptlist"
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

apt-get full-upgrade -y
apt-get --purge autoremove -y

restore_maintenance_mode
cfg="$(jq "." "$NCPCFG")"
cfg="$(jq ".release = \"trixie\"" <<<"$cfg")"
echo "$cfg" > "$NCPCFG"
rm -f /etc/update-motd.d/30ncp-dist-upgrade
rm -f /usr/local/etc/ncp-recommended.cfg

echo "Update to Debian 13 (trixie) successful."

is_active_app unattended-upgrades && {
  echo "Setting up unattended upgrades..."
  run_app unattended-upgrades || true
  echo "done."
}