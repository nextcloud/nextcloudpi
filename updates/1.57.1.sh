#!/usr/bin/env bash
set -eu

source /usr/local/etc/library.sh

echo "Reconfigure automatic preview generation (if enabled)"
run_app nc-previews-auto
echo "done."

if [[ ! -e /usr/share/keyrings/debsuryorg-archive-keyring.gpg ]]
then
  echo "Setup sury package repository key"
  apt-get update
  curl -sSLo /tmp/debsuryorg-archive-keyring.deb https://packages.sury.org/debsuryorg-archive-keyring.deb
  dpkg -i /tmp/debsuryorg-archive-keyring.deb
  echo "deb [signed-by=/usr/share/keyrings/debsuryorg-archive-keyring.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list
  apt-get update

  echo "done."
fi
