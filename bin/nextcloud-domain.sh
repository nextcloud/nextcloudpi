#!/bin/bash

source /usr/local/etc/library.sh

# wait until user decrypts the instance first
while :; do
  needs_decrypt || break
  sleep 1
done

# wicd service finishes before completing DHCP
while :; do
  local_ip="$(get_ip)"
  pub_ip="$(curl -m4 icanhazip.com 2>/dev/null)"

  [[ "$pub_ip"   != "" ]] && ncc config:system:set trusted_domains 11 --value="$pub_ip"
  [[ "$local_ip" != "" ]] && break

  sleep 3
done

ncc config:system:set trusted_domains 1  --value="${local_ip}"
ncc config:system:set trusted_domains 14 --value="$(hostname -f)"

# we might need to retry if redis is not ready
while :; do
  nc_domain="$(ncc config:system:get overwrite.cli.url)" || {
    sleep 3
    continue
  }
  # Fix the situation where junk was introduced in the config by mistake
  # because Redis was not yet ready to be used even if it was up
  [[ "${nc_domain}" =~ "RedisException" ]] && nc_domain="$(hostname)"
  set-nc-domain "${nc_domain}" >> /var/log/ncp.log
  break
done
