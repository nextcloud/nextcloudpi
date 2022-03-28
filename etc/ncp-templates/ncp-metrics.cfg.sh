#!/usr/bin/env bash

set -e
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

declare -a BKP_DIRS


DATADIR=$( ncc config:system:get datadirectory ) || {
  echo -e "ERROR: Could not get data directory. Is NextCloud running?";
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

SNAP_PATTERN=".*_(?P<year>\\\\d+)-(?P<month>\\\\d+)-(?P<day>\\\\d+)_(?P<hour>\\\\d{2})(?P<minute>\\\\d{2})(?P<second>\\\\d{2})"
cat <<EOF
    {
      "path": "${NC_SNAPSHOTS_DIR}",
      "pattern": "${SNAP_PATTERN}"
    }
EOF

[[ -z "$NC_SNAPSHOTS_SYNC_DIR" ]] || {
  cat <<EOF
    ,{
      "path": "${NC_SNAPSHOTS_SYNC_DIR}",
      "pattern": "${SNAP_PATTERN}"
    }
EOF
}

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

for BKP_DIR in "$NC_BACKUP_DIR" "$NC_BACKUP_AUTO_DIR"
do
  [[ -n "$BKP_DIR" ]] || continue
  cat <<EOF
    ,{
      "path": "$BKP_DIR",
      "pattern": "nextcloud-bkp_(?P<year>\\\\d{4})(?P<month>\\\\d{2})(?P<day>\\\\d{2})_.*\\\\.tar(\\\\.gz)?"
    }
EOF
done

cat <<EOF
  ]
}
EOF
