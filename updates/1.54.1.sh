#!/usr/bin/env bash

set -e
echo "Reenable erroneously disabled package sources"
for aptlist in /etc/apt/sources.list /etc/apt/sources.list.d/{php.list,armbian.list,raspi.list}
do
  [ -f "$aptlist" ] && sed -i -e "s/#deb /deb /g" "$aptlist"
done
echo "done"

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends zstd

. /etc/os-release

if [[ "$VERSION_ID" -eq 12 ]]
then
  DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
  rm -f /usr/local/etc/ncp-recommended.cfg
fi
