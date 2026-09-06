  #!/usr/bin/env bash

set -euo pipefail

source /usr/local/etc/library.sh

install_template "php/pool.d.www.conf.sh" "/etc/php/${PHPVER}/fpm/pool.d/www.conf"

systemctl daemon-reload
