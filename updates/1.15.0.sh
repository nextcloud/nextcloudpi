#!/bin/bash

set -e

## BACKWARD FIXES ( for older images )

source /usr/local/etc/library.sh

# all images

# docker images only
[[ -f /.docker-image ]] && {
:
}

# for non docker images
[[ ! -f /.docker-image ]] && {
# Update btrfs-sync
wget -q https://raw.githubusercontent.com/nachoparker/btrfs-sync/master/btrfs-sync -O /usr/local/bin/btrfs-sync
}

exit 0
