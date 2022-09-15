#!/usr/bin/env bash

set -e
set +u
source /usr/local/etc/library.sh

if [[ "$1" == "--defaults" ]]
then
  echo "INFO: Restoring template to default settings" >&2
  cat <<EOF
{
  "backups": []
}
EOF
  exit 0
fi

cat <<EOF
{
  "backups": [
EOF

NC_BACKUP_DIR="$(
  source "${BINDIR}/BACKUPS/nc-backup.sh"
  tmpl_get_destination
)"

NC_BACKUP_AUTO_DIR="$(
 source "${BINDIR}/BACKUPS/nc-backup-auto.sh"
 tmpl_get_destination
)"
if [[ "$NC_BACKUP_DIR" == "$NC_BACKUP_AUTO_DIR" ]]
then
  NC_BACKUP_AUTO_DIR=""
fi

NC_BACKUP_PATTERN="nextcloud-bkp_(?P<year>\\\\d{4})(?P<month>\\\\d{2})(?P<day>\\\\d{2})_.*\\\\.tar(\\\\.gz)?"

cat <<EOF
  {
    "path": "$NC_BACKUP_DIR",
    "pattern": "$NC_BACKUP_PATTERN"
  }
EOF
[[ -z "$NC_BACKUP_AUTO_DIR" ]] || {
  cat <<EOF
    ,{
      "path": "$NC_BACKUP_AUTO_DIR",
      "pattern": "$NC_BACKUP_PATTERN"
    }
EOF
}

is_docker || {

  DATADIR=$( get_nc_config_value datadirectory ) || {
    echo "ERROR: Could not get data directory. Is NextCloud running?" >&2
    return 1;
  }
  NC_SNAPSHOTS_DIR="$(dirname "$DATADIR")/ncp-snapshots"

  NC_SNAPSHOTS_SYNC_DIR="$(
    source "${BINDIR}/BACKUPS/nc-snapshot-sync.sh"
    if tmpl_is_destination_local
    then
      tmpl_get_destination
    fi
  )"

  for snap_dir in "$NC_SNAPSHOTS_DIR" "$NC_SNAPSHOTS_SYNC_DIR"
  do
    [[ -n "$snap_dir" ]] || continue
    cat <<EOF
    ,{
      "path": "${snap_dir}",
      "pattern": ".*_(?P<year>\\\\d+)-(?P<month>\\\\d+)-(?P<day>\\\\d+)_(?P<hour>\\\\d{2})(?P<minute>\\\\d{2})(?P<second>\\\\d{2})"
    }
EOF
  done

}

cat <<EOF
  ]
}
EOF
