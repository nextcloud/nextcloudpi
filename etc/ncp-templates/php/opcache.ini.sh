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

cat <<EOF
zend_extension=opcache.so
opcache.interned_strings_buffer=16
opcache.revalidate_freq=60
opcache.file_cache=${TMP_DIR};
EOF
