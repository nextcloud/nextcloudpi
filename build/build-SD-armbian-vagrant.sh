#!/bin/bash

# Batch creation of NextCloudPi Armbian based images
#
# Copyleft 2023 by Tobias Knöppler
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage: sudo ./build-SD-armbian-vagrant.sh <board_code> [<board_name>]
#

[[ "$UID" == 0 ]] || {
  echo "This script needs to be run as root. Try sudo"
  exit 1
}

set -ex
export BOARD_ID="${1?}"
export BOARD_NAME="${2:-$1}"
vagrant plugin list | grep vagrant-libvirt || vagrant plugin install vagrant-libvirt
vagrant plugin list | grep vagrant-sshfs || vagrant plugin install vagrant-sshfs
export VAGRANT_DEFAULT_PROVIDER=libvirt

vagrant box list | grep generic/ubuntu2204 || vagrant box add --provider libvirt generic/ubuntu2204

cd "$(dirname "$0")/armbian"
mkdir -p "../../output"
trap 'echo "Cleaning up vagrant..."; vagrant halt; vagrant destroy -f' EXIT
BOARD_ID="$BOARD_ID" BOARD_NAME="$BOARD_NAME" vagrant up --provider=libvirt

exit 0
