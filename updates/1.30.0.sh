#!/bin/bash

set -e

## BACKWARD FIXES ( for older images )

source /usr/local/etc/library.sh # sets NCVER PHPVER RELEASE

# all images

# make sure these are installed as well in all upgrade paths
apt_install php${PHPVER}-gmp haveged lsb-release php-smbclient exfat-fuse exfat-utils file

# for NC19.0.1
apt_install php-bcmath

## delayed in bg so it does not kill the connection, and we get AJAX response
bash -c "sleep 3; service php${PHPVER}-fpm restart" &>/dev/null &


# docker images only
[[ -f /.docker-image ]] && {
  :
}

# for non docker images
[[ ! -f /.docker-image ]] && {
  :
}

exit 0
