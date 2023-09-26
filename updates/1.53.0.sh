#!/usr/bin/env bash

set -x

source /usr/local/etc/library.sh

REDIS_CONF="/etc/redis/redis.conf"
export REDIS_PASSWORD="$( grep "^requirepass" "${REDIS_CONF}" | cut -f2 -d' ' )"
ncc config:import <<EOF
{
  "system": {
    "redis": {
      "host": "127.0.0.1",
      "port": 6379,
      "timeout": 5.0,
      "password": "$REDIS_PASSWORD"
    }
  }
}
EOF
systemctl stop redis-server
rm "${REDIS_CONF}"
rm -f /etc/systemd/system/redis-server.service.d/lxc_fix.conf
apt-get remove --purge -y redis-server

command -v docker || install_app docker.sh

mkdir -p "$(dirname "$REDIS_CONF")"
install_template redis.conf.sh "$REDIS_CONF"
install_template systemd/redis.service.sh /etc/systemd/system/redis.service --defaults
echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf
systemctl enable --now redis

clear_opcache

count=1
while ! { docker exec ncp-redis redis-cli -a "${REDIS_PASSWORD}" ping 2> /dev/null | grep PONG; }
do
  if [[ $count -ge 10 ]]
  then
    echo 'Failed to setup redis' >&2
    exit 1
  fi
  count=$((count+1))
  sleep 1
done
ncc status
