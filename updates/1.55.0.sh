#!/usr/bin/env bash

cat > /home/www/ncp-backup-launcher.sh <<'EOF'
#!/bin/bash
action="${1}"
file="${2}"
compressed="${3}"
grep -q '[\\&#;`|*?~<>^()[{}$&]' <<< "$*" && exit 1
[[ "${action}" == "listkopia" ]] && {
  ncp-kopia snapshot list --all --json
  exit
}
[[ "$file" =~ ".." ]] && exit 1
[[ "${action}" == "chksnp" ]] && {
  btrfs subvolume show "$file" &>/dev/null || exit 1
  exit
}
[[ "${action}" == "delsnp" ]] && {
  btrfs subvolume delete "$file" || exit 1
  exit
}
[[ -f "$file" ]] || exit 1
[[ "$file" =~ ".tar" ]] || exit 1
[[ "${action}" == "del" ]] && {
  [[ "$(file "$file")" =~ "tar archive" ]] || [[ "$(file "$file")" =~ "gzip compressed data" ]] || exit 1
  rm "$file" || exit 1
  exit
}
[[ "$compressed" != "" ]] && pigz="-I pigz"
tar $pigz -tf "$file" data &>/dev/null
EOF
