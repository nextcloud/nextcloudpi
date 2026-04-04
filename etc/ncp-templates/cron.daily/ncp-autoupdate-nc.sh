#!/usr/bin/env bash

set -e
set +u
source /usr/local/etc/library.sh

ncp_update_nc_args=""
if [[ "$1" != "--defaults" ]]
then
  ncp_update_nc_args="$(
    source "${BINDIR}/UPDATES/nc-autoupdate-nc.sh"
    tmpl_ncp_update_nc_args
  )"
fi

cat <<EOF
#!/bin/bash
source /usr/local/etc/library.sh

echo -e "[ncp-update-nc]"                                    >> /var/log/ncp.log
/usr/local/bin/ncp-update-nc ${ncp_update_nc_args} "latest" 2>&1 | tee -a /var/log/ncp.log

if [[ \${PIPESTATUS[0]} -eq 0 ]]; then

  VER="\$(nc_version)"

  notify_admin "NextCloudPi" "Nextcloud was updated to \$VER"
fi
echo "" >> /var/log/ncp.log
EOF