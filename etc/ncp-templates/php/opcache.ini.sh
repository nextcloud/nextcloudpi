#! /bin/bash

set -e
set +u
source /usr/local/etc/library.sh

PHPVER="${PHPVER?ERROR: PHPVER variable unset!}"

if [[ "$1" != "--defaults" ]]
then
  TMP_DIR="$(source "${BINDIR}/CONFIG/nc-datadir.sh"; tmpl_opcache_tmp_dir)"
else
  echo -e "INFO: Restoring template to default settings"

  TMP_DIR="/tmp"
fi

  cat > "/etc/php/${PHPVER}/mods-available/opcache.ini" <<EOF
zend_extension=opcache.so
opcache.enable=1
opcache.enable_cli=1
opcache.fast_shutdown=1
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=10000
opcache.memory_consumption=128
opcache.save_comments=1
opcache.revalidate_freq=1
opcache.file_cache=${TMP_DIR};
EOF
