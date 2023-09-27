#!/usr/bin/env bash

[[ -f /usr/local/etc/instance.cfg ]] || {
  cohorte_id=$((RANDOM % 100))
  cat > /usr/local/etc/instance.cfg <<EOF
{
  "cohorteId": ${cohorte_id},
  "canary": false
}
EOF
}
