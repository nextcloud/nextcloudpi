#!/usr/bin/env bash

if getent passwd "root" | grep -e '/usr/sbin/nologin'
then
  chsh -s /bin/bash root
  passwd -l root
  sed -i -e 's/^PermitRootLogin.*$/PermitRootLogin No/' /etc/ssh/sshd_config
fi

apt-get update
apt-get install --no-install-recommends -y tmux
