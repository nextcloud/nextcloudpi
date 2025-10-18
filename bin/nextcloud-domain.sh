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

  pub_ipv4="$(curl -4 -m4 icanhazip.com 2>/dev/null)"
  pub_ipv6="$(curl -6 -m4 icanhazip.com 2>/dev/null)"
  [[ -z "$pub_ipv4" ]] || ncc config:system:set trusted_domains 11 --value="$pub_ipv4"
  [[ -z "$pub_ipv6" ]] || ncc config:system:set trusted_domains 12 --value="[$pub_ipv6]"

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

