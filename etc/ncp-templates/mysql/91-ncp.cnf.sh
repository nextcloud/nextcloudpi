#!/usr/bin/env bash

set -e

if [[ "$1" == "--defaults" ]]
then
  echo -e "INFO: Restoring template to default settings"
  INNODB_BUFFER_POOL_SIZE=256M
else
  INNODB_BUFFER_POOL_SIZE="$(tmpl_innodb_buffer_pool_size)"
fi

cat > /etc/mysql/mariadb.conf.d/91-ncp.cnf <<EOF
[mysqld]
transaction_isolation = READ-COMMITTED
innodb_large_prefix=true
innodb_file_per_table=1
innodb_file_format=barracuda

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
