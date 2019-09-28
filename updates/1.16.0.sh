#!/bin/bash

set -e

## BACKWARD FIXES ( for older images )

source /usr/local/etc/library.sh

# all images

# restore smbclient after dist upgrade
apt_install php-smbclient exfat-fuse exfat-utils

# install lsb-release
apt_install lsb-release

# tweak previews
ncc config:app:set preview jpeg_quality --value="60"

# missed some sources
sed -i "s/stretch/$RELEASE/g" /etc/apt/sources.list.d/* &>/dev/null || true

# docker images only
[[ -f /.docker-image ]] && {
:
}

# for non docker images
[[ ! -f /.docker-image ]] && {
  # Update btrfs-sync
  wget -q https://raw.githubusercontent.com/nachoparker/btrfs-sync/master/btrfs-sync -O /usr/local/bin/btrfs-sync
  chmod +x /usr/local/bin/btrfs-sync

  # work around dhcpcd Raspbian bug
  # https://lb.raspberrypi.org/forums/viewtopic.php?t=230779
  # https://github.com/nextcloud/nextcloudpi/issues/938
  test -f /usr/bin/raspi-config && {
    apt-get update
    apt_install haveged
    systemctl enable haveged.service
  }

  # Update btrfs-snp
  wget https://raw.githubusercontent.com/nachoparker/btrfs-snp/master/btrfs-snp -O /usr/local/bin/btrfs-snp
  chmod +x /usr/local/bin/btrfs-snp
}

exit 0
