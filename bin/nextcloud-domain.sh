#!/bin/bash

source /usr/local/etc/library.sh

# wicd service finishes before completing DHCP
while :; do
  ip="$(get_ip)"
  public_ip="$(curl -m4 icanhazip.com 2>/dev/null)"

  [[ "$public_ip" != "" ]] && ncc config:system:set trusted_domains 11 --value="$public_ip"
  [[ "$ip" != "" ]] && break

  sleep 3
done

ncc config:system:set trusted_domains "${TRUSTED_DOMAINS[ip]}"       --value="${ip}"
ncc config:system:set trusted_domains "${TRUSTED_DOMAINS[hostname]}" --value="$(hostname -f)"

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
