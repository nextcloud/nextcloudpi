#! /bin/bash

set -e
source /usr/local/etc/library.sh

PHPVER="${PHPVER?ERROR: PHPVER variable unset!}"

if [[ "$1" == "--defaults" ]] || ! [[ -f "${BINDIR}/CONFIG/nc-datadir.sh" ]]
then
  echo "INFO: Restoring template to default settings" >&2

  TMP_DIR="/tmp"
else
  TMP_DIR="$(source "${BINDIR}/CONFIG/nc-datadir.sh"; tmpl_opcache_dir)"
fi
# Workaround for https://github.com/php/php-src/issues/7817
ENABLE_OPCACHE="1"
[[ "$PHPVER" != '8.1' ]] || ENABLE_OPCACHE='0'

cat <<EOF
zend_extension=opcache.so
opcache.enable=${ENABLE_OPCACHE}
opcache.enable_cli=1
opcache.fast_shutdown=1
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=10000
opcache.memory_consumption=128
opcache.save_comments=1
opcache.revalidate_freq=1
opcache.file_cache=${TMP_DIR};
EOF
