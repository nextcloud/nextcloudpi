#!/bin/bash

set -eu -o pipefail

[[ -f /.dockerenv ]] && { echo "Not supported in Docker. Upgrade the container instead"; exit 0; }

new_cfg=/usr/local/etc/ncp-recommended.cfg
[[ -f "${new_cfg}" ]] || { echo "Already on the lastest recommended distribution. Abort." >&2; exit 1; }

APTINSTALL="apt-get install -y --no-install-recommends"
export DEBIAN_FRONTEND=noninteractive

echo "
>>> ATTENTION <<<
This is a dangerous process that is only guaranteed to work properly if you
have not made manual changes in the system. Backup the SD card first and
proceed at your own risk.

Note that this is not a requirement for NCP to continue working properly.
The current distribution will keep receiving updates for some time.

Do you want to continue? [y/N]"

read key
[[ "$key" == y ]] || exit 0

source /usr/local/etc/library.sh # sets NCPCFG RELEASE PHPVER
old_cfg="${NCPCFG}"

trap "echo 'Something went wrong. Fix it and try again'" EXIT

save_maintenance_mode

# Fix grub-pc issue in VM
if apt show grub-pc-bin &>/dev/null; then
  $APTINSTALL grub
fi

apt-get update
apt-get upgrade -y

# remove old PHP version
set +e
apt-get purge -y php${PHPVER} php${PHPVER}-curl php${PHPVER}-gd php${PHPVER}-fpm php${PHPVER}-cli php${PHPVER}-opcache \
	php${PHPVER}-mbstring php${PHPVER}-xml php${PHPVER}-zip php${PHPVER}-fileinfo php${PHPVER}-ldap \
	php${PHPVER}-intl php${PHPVER}-bz2 php${PHPVER}-json
apt-get purge -y php${PHPVER}-mysql
apt-get purge -y php${PHPVER}-redis
apt-get purge -y php${PHPVER}-exif
apt-get purge -y php${PHPVER}-bcmath
apt-get purge -y php${PHPVER}-gmp
apt-get purge -y php${PHPVER}-imagick
set -e

# update sources
sed -i 's/buster/bullseye/g' /etc/apt/sources.list
sed -i 's/buster/bullseye/g' /etc/apt/sources.list.d/* || true
sed -i 's/bullseye\/updates/bullseye-security/g' /etc/apt/sources.list
rm -f /etc/apt/sources.list.d/php.list

# fix DHCP systemd service command https://forums.raspberrypi.com/viewtopic.php?t=320383 in raspbian
if [[ -f /usr/bin/raspi-config ]]; then
  sed -i 's|ExecStart=/usr/lib/dhcpcd5/dhcpcd -q -w|ExecStart=/usr/sbin/dhcpcd -q -w|g' /etc/systemd/system/dhcpcd.service.d/wait.conf
fi

# install latest distro
apt-get update
apt-get dist-upgrade -y

# install latest PHP version
release_new=$(jq -r '.release'     < "${new_cfg}")
# the default repo in bullseye is bullseye-security - use bullseye if it is not available
grep -Eh '^deb ' /etc/apt/sources.list | grep 'bullseye-security' > /dev/null && release_new="${release_new}-security"
php_ver_new=$(jq -r '.php_version' < "${new_cfg}")
# PHP 8.1 is only supported via the
[[ "$php_ver_new" != 8.1 ]] || php_ver_new=7.4

$APTINSTALL -t ${release_new} php${php_ver_new} php${php_ver_new}-curl php${php_ver_new}-gd php${php_ver_new}-fpm php${php_ver_new}-cli php${php_ver_new}-opcache \
	php${php_ver_new}-mbstring php${php_ver_new}-xml php${php_ver_new}-zip php${php_ver_new}-fileinfo php${php_ver_new}-ldap \
	php${php_ver_new}-intl php${php_ver_new}-bz2 php${php_ver_new}-json

$APTINSTALL php${php_ver_new}-mysql
$APTINSTALL -t ${release_new} php${php_ver_new}-redis

$APTINSTALL -t ${release_new} smbclient exfat-fuse exfat-utils
sleep 2 # avoid systemd thinking that PHP is in a crash/restart loop
$APTINSTALL -t ${release_new} php${php_ver_new}-exif
sleep 2 # avoid systemd thinking that PHP is in a crash/restart loop
$APTINSTALL -t ${release_new} php${php_ver_new}-bcmath
sleep 2 # avoid systemd thinking that PHP is in a crash/restart loop
$APTINSTALL -t ${release_new} php${php_ver_new}-gmp
#$APTINSTALL -t ${release_new} imagemagick php${php_ver_new}-imagick ghostscript

# Reinstall prometheus-node-exporter, specifically WITH install-recommends to include collectors on bullseye and later
{ dpkg -l | grep '^ii.*prometheus-node-exporter' >/dev/null && apt-get install -y prometheus-node-exporter-collectors; } || true

apt-get autoremove -y
apt-get clean

cat > /etc/php/${php_ver_new}/fpm/conf.d/90-ncp.ini <<EOF
; disable .user.ini files for performance and workaround NC update bugs
user_ini.filename =

; from Nextcloud .user.ini
upload_max_filesize=10G
post_max_size=10G
memory_limit=768M
mbstring.func_overload=0
always_populate_raw_post_data=-1
default_charset='UTF-8'
output_buffering=0

; slow transfers will be killed after this time
max_execution_time=3600
max_input_time=3600
EOF

# restart services
service php${php_ver_new}-fpm restart
a2enconf php${php_ver_new}-fpm
service apache2 restart

is_active_app unattended-upgrades && run_app unattended-upgrades || true

# mark as successful
mv "${new_cfg}" "${old_cfg}"
install_template "php/opcache.ini.sh" "/etc/php/${php_ver_new}/mods-available/opcache.ini" --defaults
clear_opcache

source /usr/local/etc/library.sh # refresh NCPCFG RELEASE PHPVER
run_app nc-limits
restore_maintenance_mode

rm -f /etc/update-motd.d/30ncp-dist-upgrade

echo "Upgrade to ${release_new} successful"
trap '' EXIT
