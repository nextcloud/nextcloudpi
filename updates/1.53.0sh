#!/usr/bin/env bash

[[ -f /usr/local/etc/instance.cfg ]] || {
  cohorte_id=$((RANDOM % 100))
  cat > /usr/local/etc/instance.cfg <<EOF
{
  "cohorteId": ${cohorte_id}
}
EOF
}

cat > /home/www/ncp-app-bridge.sh <<'EOF'
#!/bin/bash
set -e
grep -q '[\\&#;`|*?~<>^()[{}$&]' <<< "$*" && exit 1
action="${1?}"
[[ "$action" == "config" ]] && {
  config_type="${2?}"
  arg="${3}"

  [[ -z "$arg" ]] || {
    key="${arg%=*}"
    val="${arg#*=}"
  }

  if [[ "$config_type" == "ncp" ]]
  then
    config_path="/usr/local/etc/ncp.cfg"
  elif [[ "$config_type" == "ncp-community" ]]
  then
    . /usr/local/etc/library.sh
    [[ -z "${key}" ]] || {
      set_app_param ncp-community.sh "${key}" "${val}"
    }
    get_app_params ncp-community.sh
    exit $?
  else
    echo "ERROR: Invalid config name '${config_type}'" >&2
    exit 1
  fi

  [[ -z "${key}" ]] || {
    cfg="$(jq ".${key} = \"${val}\"" <"$config_path")"
    echo "$cfg" > "$config_path"
  }
  cat "$config_path"
  exit 0
}

[[ "$action" == "file" ]] && {
  file="${2?}"
  if [[ "$file" == "ncp-version" ]]
  then
    cat /usr/local/etc/ncp-version
  else
    echo "ERROR: Invalid file '${file}'" >&2
    exit 1
  fi
  exit 0
}
EOF
chmod 700 /home/www/ncp-app-bridge.sh
sed -i 's|www-data ALL = NOPASSWD: .*|www-data ALL = NOPASSWD: /home/www/ncp-launcher.sh , /home/www/ncp-backup-launcher.sh, /home/www/ncp-app-bridge.sh, /sbin/halt, /sbin/reboot|' /etc/sudoers

ncc upgrade
