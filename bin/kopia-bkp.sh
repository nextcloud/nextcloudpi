#!/usr/bin/env bash

set -e

export KOPIA_PASSWORD="${KOPIA_PASSWORD?}"

source /usr/local/etc/library.sh

kopia_flags=(--config-file=/usr/local/etc/kopia/repository.config --log-dir="/var/log/kopia" --no-persist-credentials)
data_dir="$(source "${BINDIR}/CONFIG/nc-data_dir.sh"; tmpl_data_dir)"
cache_dir="${data_dir}/.kopia"
mkdir -p "${cache_dir}"

data_subvol="$(dirname "$data_dir")"

backup_dir="$(dirname "${data_subvol}")/kopia"
mkdir -p "$backup_dir"

db_backup_file="nextcloud-sqlbkp.sql"
mysqldump -u root --single-transaction nextcloud > "${backup_dir}/${db_backup_file}"

cleanup_btrfs() {
  btrfs subvolume delete "${backup_dir?}/ncdata"
}

cleanup_mount_bind() {
  local ret=$?
  umount "${backup_dir?}/ncdata" || umount -f "${backup_dir?}/ncdata" || umount -l "${backup_dir?}/ncdata"
  restore_maintenance_mode
  return $?
}

cleanup(){
  local ret=$?
  umount "${backup_dir}/nextcloud" || umount -f "${backup_dir}/nextcloud" || umount -l "${backup_dir}/nextcloud"
  umount "${backup_dir}/ncp-config.d" || umount -f "${backup_dir}/ncp-config.d" || umount -l "${backup_dir}/ncp-config.d"
  rm -f "${backup_dir?}/${db_backup_file?}"
  remnants=()
  for f in "${backup_dir}"/*
  do
    remnants+=("$f")
  done
  if [[ -n "${remnants[*]}" ]]
  then
    msg="$(printf "WARN: Files/directories remaining in backup directory after cleanup: \n%s" "${remnants[*]}")"
    echo "$msg" >&2
    notify_admin "Kopia backup failed: $msg"
  fi
  restore_maintenance_mode
  exit $ret
}

if [[ "$( stat -fc%T "$data_subvol" )" == "btrfs" ]] && btrfs subvolume show "$data_subvol" 2>/dev/null
then
  trap 'cleanup_btrfs; cleanup' EXIT
  unset NCP_MAINTENANCE_MODE
  btrfs subvolume snapshot -r "${data_subvol?}" "${backup_dir}/ncdata"
else
  trap 'cleanup_mount_bind; cleanup' EXIT
  save_maintenance_mode
  mount --bind -o ro "${mountpoint?}" "${backup_dir}/ncdata"
fi

mount --bind -o ro "/var/www/nextcloud" "${backup_dir}/nextcloud"
mount --bind -o ro "/usr/locl/etc/ncp-config.d" "${backup_dir}/ncp-config.d"

kopia "${kopia_flags[@]}" snapshot create \
  --tags="trigger:schedule" --tags="includes-db:yes" --tags="includes-files:yes" --tags="includes-nextcloud:yes" --tags="includes-ncp-config:yes" \
  "${backup_dir?}"
