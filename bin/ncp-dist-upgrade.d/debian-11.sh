#!/bin/bash

set -eu -o pipefail


new_cfg=/usr/local/etc/ncp-recommended.cfg
[[ -f "${new_cfg}" ]] || { echo "Already on the lastest recommended distribution. Abort." >&2; exit 1; }

export DEBIAN_FRONTEND=noninteractive

echo "
>>> ATTENTION <<<
This is a dangerous process that is only guaranteed to work properly if you
have not made manual changes in the system. Backup the SD card first and
proceed at your own risk.

Note that this is not a requirement for NCP to continue working properly.
The current distribution will keep receiving updates for some time.

Do you want to continue? [y/N]"

read -n1 -r key
[[ "${key,,}" == y ]] || exit 0

source /usr/local/etc/library.sh
save_maintenance_mode

# Perform dist-upgrade

apt-get update && apt-get upgrade -y
for aptlist in /etc/apt/sources.list /etc/apt/sources.list.d/php.list
do
	sed -i -e "s/bullseye/bookworm/g" "$aptlist"
done
for aptlist in /etc/apt/sources.list.d/*.list
do
	[[ "$aptlist" != "/etc/apt/sources.list.d/php.list" ]] || continue
    echo "Disabling repositories from \"$aptlist\""
    sed -i -e "s/deb/#deb/g" "$aptlist"
done
apt-get update && apt-get upgrade -y --without-new-pkgs
# Required to avoid breakage of /etc/resolv.conf
apt-get install -y --no-install-recommends systemd-resolved && systemctl enable --now systemd-resolved
apt-get full-upgrade -y

restore_maintenance_mode
cfg="$(jq "." "$NCPCFG")"
cfg="$(jq ".release = \"bookworm\"" <<<"$cfg")"
echo "$cfg" > "$NCPCFG"
echo "Update to Debian 12 (bookworm) successful."

is_active_app unattended-upgrades && {
  echo "Setting up unattended upgrades..."
  run_app unattended-upgrades || true
  echo "done."
}