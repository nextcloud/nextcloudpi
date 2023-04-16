#!/usr/bin/env bash

set -e
source /usr/local/etc/library.sh

if [[ "$1" == "--defaults" ]]
then
  echo "INFO: Restoring template to default settings" >&2
  INNODB_BUFFER_POOL_SIZE=256M
else
  INNODB_BUFFER_POOL_SIZE="$(source "${BINDIR}/CONFIG/nc-limits.sh"; tmpl_innodb_buffer_pool_size)"
fi

cat <<EOF
[mysqld]
transaction_isolation = READ-COMMITTED
innodb_large_prefix=true
innodb_file_per_table=1
innodb_file_format=barracuda
max_allowed_packet=256M

[server]
# innodb settings
skip-name-resolve
innodb_buffer_pool_size = ${INNODB_BUFFER_POOL_SIZE}
innodb_buffer_pool_instances = 1
innodb_flush_log_at_trx_commit = 2
innodb_log_buffer_size = 32M
innodb_max_dirty_pages_pct = 90
innodb_log_file_size = 32M

# disable query cache
query_cache_type = 0
query_cache_size = 0

# other
tmp_table_size= 64M
max_heap_table_size= 64M
EOF
