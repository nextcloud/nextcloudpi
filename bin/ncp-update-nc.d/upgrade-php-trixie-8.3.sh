#!/usr/bin/env bash

source /usr/local/etc/library.sh

echo "Refreshing PHP repository for trixie..."
export DEBIAN_FRONTEND=noninteractive

# Refresh sury repo for trixie
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ ${RELEASE%-security} main" > /etc/apt/sources.list.d/php.list
apt-get update

echo "PHP ${PHPVER} repository updated for trixie."