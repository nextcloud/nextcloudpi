#!/bin/bash

set -e

## BACKWARD FIXES ( for older images )

source /usr/local/etc/library.sh # sets NCVER PHPVER RELEASE

# all images

# disable old TLS versions
file=/etc/apache2/conf-available/http2.conf
grep -q '^SSLProtocol all -SSLv2 -SSLv3' "${file}" && {
  sed -i 's|^SSLProtocol .*|SSLProtocol -all +TLSv1.2|' "${file}"
  bash -c "sleep 10 && service apache2 reload" &>/dev/null &
}

# docker images only
[[ -f /.docker-image ]] && {
  :
}

# for non docker images
[[ ! -f /.docker-image ]] && {
  :
}

exit 0
