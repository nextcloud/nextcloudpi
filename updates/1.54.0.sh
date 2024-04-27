#!/usr/bin/env bash

if getent passwd "$LOGNAME" | grep -e 'root' | grep -e '/usr/sbin/nologin'
then
  chsh -s /bin/bash root
  passwd -l root
fi