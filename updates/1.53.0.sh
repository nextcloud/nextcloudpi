#!/usr/bin/env bash

source /usr/local/etc/library.sh

systemctl stop redis-server
REDIS_CONF="/etc/redis/redis.conf"
rm "${REDIS_CONF}"
rm /etc/systemd/system/redis-server.service.d/lxc_fix.conf
apt-get remove --purge redis-server

command -v docker || install_app docker.sh

mkdir -p "$(dirname "$REDIS_CONF")"
install_template redis.conf.sh "$REDIS_CONF" --defaults
install_template systemd/redis.service.sh /etc/systemd/system/redis.service --defaults
echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf
systemctl daemon-reload
systemctl enable --now redis
clear_opcache
