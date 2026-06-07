#!/bin/bash

set -eu -o pipefail

export DEBIAN_FRONTEND=noninteractive

source /usr/local/etc/library.sh
is_more_recent_than "${PHPVER}.0" "8.2.0" || {
  echo "You still have PHP version ${PHPVER} installed. Please update to the latest supported version of nextcloud (which will also update your PHP version) before proceeding with the distribution upgrade."
  echo "Exiting."
  exit 1
}
save_maintenance_mode

# Perform dist-upgrade
set -x

# Make sure, PHP repo is properly setup
curl -sSLo /tmp/debsuryorg-archive-keyring.deb https://packages.sury.org/debsuryorg-archive-keyring.deb
dpkg -i /tmp/debsuryorg-archive-keyring.deb
echo "deb [signed-by=/usr/share/keyrings/debsuryorg-archive-keyring.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list

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