#!/usr/bin/env bash

. /etc/os-release

if [[ "$VERSION_ID" -eq 12 ]]
then
  rm -f /usr/local/etc/ncp-recommended.cfg
fi

DEBIAN_FRONTEND=noninteractive sudo apt-get install -y --no-install-recommends zstd