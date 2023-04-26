#! /bin/bash

set -e
source /usr/local/etc/library.sh

PHPVER="${PHPVER?ERROR: PHPVER variable unset!}"

if [[ "$1" == "--defaults" ]] || ! [[ -f "${BINDIR}/CONFIG/nc-limits.sh" ]]
then
  echo "INFO: Restoring template to default settings" >&2

  PHPTHREADS=16
else
  PHPTHREADS="$(source "${BINDIR}/CONFIG/nc-limits.sh"; tmpl_php_threads)"
fi


cat <<EOF
[www]
user = www-data
group = www-data
listen = /run/php/php${PHPVER}-fpm.sock
listen.owner = www-data
listen.group = www-data
pm = static
pm.max_children = ${PHPTHREADS}
pm.start_servers = 4
pm.min_spare_servers = 4
pm.max_spare_servers = 8
pm.status_path = /status
slowlog = log/\$pool.log.slow
EOF
