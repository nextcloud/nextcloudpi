#!/bin/bash

source /usr/local/etc/library.sh

# wicd service finishes before completing DHCP
while :; do
  iface="$( ip r | grep "default via" | awk '{ print $5 }' | head -1 )"
  ip="$( ip a show dev "$iface" | grep global | grep -oP '\d{1,3}(.\d{1,3}){3}' | head -1 )"

  public_ip="$(curl icanhazip.com 2>/dev/null)"
  [[ "$public_ip" != "" ]] && ncc config:system:set trusted_domains 11 --value="$public_ip"

  [[ "$ip" != "" ]] && break
  sleep 3
done

# set "${TRUSTED_DOMAINS[ip]}"
ncc config:system:set trusted_domains 1 --value=${ip}

# we might need to retry if redis is not ready
while :; do
  nc_domain="$(ncc config:system:get overwrite.cli.url)" || {
    sleep 3
    continue
  }
  set-nc-domain "${nc_domain}" >> /var/log/ncp.log
  break
done
