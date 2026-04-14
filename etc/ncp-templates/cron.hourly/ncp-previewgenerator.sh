#!/usr/bin/env bash

cat <<'EOF'
#!/usr/bin/env bash
set -eu

GENERATE_JOB_ID="ncp-generate-previews"

if [[ "$(systemctl is-active "${GENERATE_JOB_ID}" ||:)" =~ ^(active|activating|deactivating)$ ]]
then
  echo "Existing initial preview generation process detected. Aborting..."
  exit 0
fi

source /usr/local/etc/library.sh

if is_app_enabled memories
then
  ncc config:app:set --value="256 4096" previewgenerator coverWidthHeightSizes > /dev/null
else
  ncc config:app:set --value="" previewgenerator coverWidthHeightSizes > /dev/null
fi

for _ in $(seq 1 $(nproc)); do
  ncc preview:pre-generate -n -q &
done

wait
EOF