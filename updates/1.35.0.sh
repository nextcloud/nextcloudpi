#!/bin/bash

set -e

## BACKWARD FIXES ( for older images )

source /usr/local/etc/library.sh # sets NCVER PHPVER RELEASE

# all images

is_active_app unattended-upgrades && run_app unattended-upgrades

# docker images only
[[ -f /.docker-image ]] && {
  :
}

# for non docker images
[[ ! -f /.docker-image ]] && {
  :
}

exit 0
