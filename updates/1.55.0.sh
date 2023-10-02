#!/usr/bin/env bash

cat > /home/www/ncp-backup-launcher.sh <<'EOF'
#!/bin/bash
action="${1}"
file="${2}"
compressed="${3}"
grep -q '[\\&#;`|*?~<>^()[{}$&]' <<< "$*" && exit 1
[[ "${action}" == "listkopia" ]] && {
  ncp-kopia snapshot list --all --json
  exit $?
}
[[ "${action}" == "delkopia" ]] && {
  echo "[ ncp-backup-launcher ]" | tee -a /var/log/ncp.log
  echo "Deleting kopia snapshot '${file?Missing parameter: snapshot id}'" | tee -a /var/log/ncp.log
  ncp-kopia snapshot delete "${file}"

  exit $?
}
[[ "$file" =~ ".." ]] && exit 1
[[ "${action}" == "chksnp" ]] && {
  btrfs subvolume show "$file" &>/dev/null || exit 1
  exit
}
[[ "${action}" == "delsnp" ]] && {
  echo "[ ncp-backup-launcher ]" | tee -a /var/log/ncp.log
  echo "Deleting btrfs snapshot '${file?Missing parameter: file}'" | tee -a /var/log/ncp.log
  btrfs subvolume delete "$file" || exit 1
  exit
}
[[ -f "$file" ]] || exit 1
[[ "$file" =~ ".tar" ]] || exit 1
[[ "${action}" == "del" ]] && {
  [[ "$(file "$file")" =~ "tar archive" ]] || [[ "$(file "$file")" =~ "gzip compressed data" ]] || exit 1
  echo "[ ncp-backup-launcher ]" | tee -a /var/log/ncp.log
  echo "Deleting backup '${file?Missing parameter: file}'" | tee -a /var/log/ncp.log
  rm "$file" || exit 1
  exit
}
[[ "$compressed" != "" ]] && pigz="-I pigz"
tar $pigz -tf "$file" data &>/dev/null
EOF
