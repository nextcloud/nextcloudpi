#!/usr/bin/env bash

set -e
echo "Reenable erroneously disabled package sources"
for aptlist in /etc/apt/sources.list /etc/apt/sources.list.d/{php.list,armbian.list,raspi.list}
do
  [ -f "$aptlist" ] && sed -i -e "s/#deb /deb /g" "$aptlist"
done
echo "done"
sudo apt-get update && sudo apt-get upgrade -y