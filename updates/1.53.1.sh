#!/usr/bin/env bash
set -e

source /usr/local/etc/library.sh

install_template apache2/ncp.conf.sh /etc/apache2/sites-available/ncp.conf --defaults

# Install docker
command -v podman || install_app docker.sh

# Check nested container support if running on lxc
if grep -qa container=lxc /proc/1/environ \
  && grep 'error mounting "proc" to rootfs at "/proc"' <(podman run --rm docker.io/hello-world 2>&1 1>/dev/null || true)
then
  echo "Failed to update to v1.53.1: Please enable container nesting for the NCP container (see https://docs.nextcloudpi.com)"
  notify_admin "NCP UPDATE FAILED" "Failed to update to v1.53.1: Please enable container nesting for the NCP container (see https://docs.nextcloudpi.com)"
  exit 1
fi

podman run --rm docker.io/hello-world > /dev/null || {
  echo "Failed to update to v1.53.1: Please check if the docker daemon is installed correctly and try again."
  notify_admin "NCP UPDATE FAILED" "Failed to update to v1.53.1: Please check if the docker daemon is installed correctly and try again."
  exit 1
}

# Migrate redis to docker

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
systemctl is-active redis-server >/dev/null && systemctl stop redis-server
rm "${REDIS_CONF}"
rm -f /etc/systemd/system/redis-server.service.d/lxc_fix.conf
apt-get remove --purge -y redis-server

mkdir -p "$(dirname "$REDIS_CONF")"
install_template redis.conf.sh "$REDIS_CONF"
install_template systemd/redis.service.sh /etc/systemd/system/redis.service --defaults
echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf
systemctl enable --now redis

clear_opcache

echo 'Waiting for redis to start up...'
count=1
while ! { podman exec ncp-redis redis-cli -a "${REDIS_PASSWORD}" ping 2> /dev/null | grep PONG; }
do
  if [[ $count -ge 60 ]]
  then
    echo 'Failed to setup redis' >&2
    exit 1
  fi
  count=$((count+1))
  sleep 1
done
echo 'Redis is started. Checking nextcloud connectivity...'
ncc status
echo 'Done.'
