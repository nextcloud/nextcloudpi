source /usr/local/etc/svc/nextcloud/.env

REDIS_MEM=3gb
[[ -n "$REDIS_PASSWORD" ]] || REDIS_PASSWORD="$(base64 < /dev/urandom | head -c 32)"

if [[ "$1" == "--defaults" ]]
then
  echo "INFO: Restoring template to default settings" >&2
  REDIS_PASSWORD="default"
else
  REDIS_MEM="$(source "${BINDIR}/CONFIG/nc-limits.sh"; tmpl_redis_mem)"
fi

cat <<EOF
requirepass ${REDIS_PASSWORD?}
maxmemory-policy allkeys-lru
rename-command CONFIG ""
maxmemory $REDIS_MEM
EOF
