#!/usr/bin/env bash

set -e
echo "Reenable erroneously disabled package sources"
for aptlist in /etc/apt/sources.list /etc/apt/sources.list.d/{php.list,armbian.list,raspi.list}
do
  [ -f "$aptlist" ] && sed -i -e "s/#deb /deb /g" "$aptlist"
done
echo "done"
sudo apt-get update && sudo bash -c 'DEBIAN_FRONTEND=noninteractive apt-get upgrade -y'
. /etc/os-release

if [[ "$VERSION_ID" -eq 12 ]]
then
  rm -f /usr/local/etc/ncp-recommended.cfg
fi
