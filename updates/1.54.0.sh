#!/usr/bin/env bash

if getent passwd "root" | grep -e '/usr/sbin/nologin'
then
  chsh -s /bin/bash root
  passwd -l root
  sed -i -e 's/^PermitRootLogin.*$/PermitRootLogin No/' /etc/ssh/sshd_config
fi

for i in {10..15}
do
  proxy="$(ncc config:system:get trusted_proxies "$i")"
  [[ -z "$proxy" ]] || python3 -c "import ipaddress; ipaddress.ip_address('${proxy}')" || ncc config:system:delete trusted_proxies "$i"
done

apt-key adv --fetch-keys https://packages.sury.org/php/apt.gpg

apt-get update
apt-get install --no-install-recommends -y tmux
