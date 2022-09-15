#! /bin/bash

set -e
source /usr/local/etc/library.sh

MAXTRANSFERTIME="3600"
if [[ "$1" == "--defaults" ]]
then
  MAXFILESIZE="10G"
  MEMORYLIMIT="768M"
else
  MAXFILESIZE="$(source "${BINDIR}/CONFIG/nc-limits.sh" && tmpl_php_max_filesize)"
  MEMORYLIMIT="$(source "${BINDIR}/CONFIG/nc-limits.sh" && tmpl_php_max_memory)"
  [[ -f "${BINDIR}/CONFIG/nc-nextcloud.sh" ]] && MAXTRANSFERTIME="$(source "${BINDIR}/CONFIG/nc-nextcloud.sh" && tmpl_max_transfer_time)"
fi

cat <<EOF
; disable .user.ini files for performance and workaround NC update bugs
user_ini.filename =

; from Nextcloud .user.ini
upload_max_filesize=$MAXFILESIZE
post_max_size=$MAXFILESIZE
memory_limit=$MEMORYLIMIT
mbstring.func_overload=0
always_populate_raw_post_data=-1
default_charset='UTF-8'
output_buffering=0

; slow transfers will be killed after this time
max_execution_time=$MAXTRANSFERTIME
max_input_time=$MAXTRANSFERTIME
EOF
