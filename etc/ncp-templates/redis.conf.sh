set -e
source /usr/local/etc/library.sh

REDIS_MEM=3gb

if [[ "$1" == "--defaults" ]]
then
  echo "INFO: Restoring template to default settings" >&2
  REDIS_PASSWORD="default"
else
  [ -f /usr/local/etc/svc/nextcloud/.env ] && source /usr/local/etc/svc/nextcloud/.env
  [[ -n "$REDIS_PASSWORD" ]] || REDIS_PASSWORD="$(base64 < /dev/urandom | head -c 32)"
  REDIS_MEM="$(source "${BINDIR}/CONFIG/nc-limits.sh"; tmpl_redis_mem)"
fi

cat <<EOF
requirepass ${REDIS_PASSWORD?}
maxmemory-policy allkeys-lru
rename-command CONFIG ""
maxmemory $REDIS_MEM
EOF
