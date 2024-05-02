#!/usr/bin/env bash

set -e

echo "Update root login prevention method..."
if getent passwd "root" | grep -e '/usr/sbin/nologin'
then
  chsh -s /bin/bash root
  passwd -l root
  if grep '^PermitRootLogin' /etc/ssh/sshd_config
  then
    sed -i -e 's/^PermitRootLogin.*$/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
  else
    echo 'PermitRootLogin prohibit-password' >> /etc/ssh/sshd_config
  fi
  systemctl reload ssh
fi
echo "done."

echo "Fixing trusted proxies list..."
for i in {10..15}
do
  proxy="$(ncc config:system:get trusted_proxies "$i" || echo 'NONE')"
  [[ "$proxy" == 'NONE' ]] || python3 -c "import ipaddress; ipaddress.ip_address('${proxy}')" > /dev/null 2>&1 || ncc config:system:delete trusted_proxies "$i"
done
echo "done."

echo "Updating PHP package signing key..."
apt-get update
apt-get install --no-install-recommends -y gnupg2

apt-key adv --fetch-keys https://packages.sury.org/php/apt.gpg
echo "done."

echo "Installing dependencies..."
apt-get install --no-install-recommends -y tmux
echo "done."

echo "Updating obsolete theming URL"
if [[ "$(ncc config:app:get theming url)" == "https://ownyourbits.com" ]]
then
   ncc config:app:set theming url --value="https://nextcloudpi.com"
fi
echo "done."
