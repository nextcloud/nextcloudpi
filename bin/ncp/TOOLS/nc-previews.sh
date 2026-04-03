#!/bin/bash

# Generate previews for the gallery
#
# Copyleft 2018 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at nextcloudpi.com
#

GENERATE_LOG="/var/log/ncp-generate-previews.log"
GENERATE_JOB_ID="ncp-generate-previews"

connect_to_preview_generation() {
  tail -n 100 -f "${GENERATE_LOG}" &
  tail_pid=$!
  trap "kill '$tail_pid'" EXIT
  while [[ "$(systemctl is-active "${GENERATE_JOB_ID}" ||:)" =~ ^(active|activating|deactivating)$ ]]
  do
    sleep 3
  done

  if [[ "$(systemctl is-active "${GENERATE_JOB_ID}" ||:)" == "inactive" ]]
  then
    echo "Preview generation finished successfully."
    return 0
  elif [[ "$(systemctl is-active "${GENERATE_JOB_ID}" ||:)" == "failed" ]]
  then
    echo "Preview generation failed (or was installed already)."
    return 1
  else
    echo "Preview generation was not found or failed (unexpected status: '$(systemctl is-active "${GENERATE_JOB_ID}" ||:)')"
  fi
}


configure()
{
  # Disable during build
  ! [[ -f /.ncp-image ]] || return 0


  if [[ "$(systemctl is-active "${GENERATE_JOB_ID}" ||:)" =~ ^(active|activating|deactivating)$ ]]
  then
    echo "Existing preview generation process detected. Connecting..."
    connect_to_preview_generation
    exit $?
  fi

  if ! [[ -f /.ncp-image ]]
  then
    ncc app:getpath previewgenerator > /dev/null || ncc app:install previewgenerator
    is_app_enabled previewgenerator || ncc app:enable previewgenerator
    ncc config:app:set --value="64 256" previewgenerator squareSizes
    ncc config:app:set --value="256 4096" previewgenerator fillWidthHeightSizes
    ncc config:app:set --value="64 256 1024" previewgenerator widthSizes
    ncc config:app:set --value="64 256 1024" previewgenerator heightSizes
    if is_app_enabled memories
    then
      ncc config:app:set --value="256 4096" previewgenerator coverWidthHeightSizes
    else
      ncc config:app:set --value="" previewgenerator coverWidthHeightSizes
    fi
  fi

  tmpscript="$(mktemp /run/ncp-preview-generate.XXXXXX)"

  PROC="$(nproc)"
  if [[ "$PROC" -gt 3 ]]
  then
    PROC="$((PROC-2))"
  else
    PROC=1
  fi

  [[ "$CLEAN" == "yes" ]] && {
    if ! is_more_recent_than "$(nc_version)" 30.99.99
    then
      echo "ERROR: CLEAN not supported for Nextcloud < 31 (was $(nc_version))"
      return
    else
      echo 'echo "Cleaning old previews. This can take a while ..."' >> "$tmpscript"
      echo 'ncc preview:cleanup' >> "$tmpscript"
    fi
  }

  [[ "$INCREMENTAL" == "yes" ]] && {
    cat <<EOF >> "$tmpscript"
for _ in $PROC; do
  ncc preview:pre-generate -n -vvv &
done
wait
EOF
    return
  }

  [[ "$PATH1" != "" ]] && PATH_ARG=(-p "$PATH1")
  echo "ncc preview:generate-all -w \"${PROC}\" -n -vv " "${PATH_ARG[@]}" >> "$tmpscript"

  systemctl reset-failed "${GENERATE_JOB_ID}" 2>/dev/null ||:
  systemd-run -u "${GENERATE_JOB_ID}" --service-type=oneshot --no-block -p TimeoutStartSec="72h" -p TimeoutStopSec="1h" \
    bash -c "bash '$tmpscript' |& tee '$GENERATE_LOG'"
  sleep 1

  if ! [[ "$(systemctl is-active "${GENERATE_JOB_ID}" ||:)" =~ ^(active|inactive|activating|deactivating)$ ]]
  then
    echo "Failed to start preview generation job"
    [[ -f "${GENERATE_LOG}" ]] && cat "${GENERATE_LOG}"
    systemctl status --no-pager "${GENERATE_JOB_ID}" ||:
    exit 1
  fi

  echo "Preview generation started. You can safely close this session, the job will keep running in the background."

  [[ "${PREVIEW_GENERATION_DETACH:-false}" == "true" ]] || connect_to_preview_generation
}

install() { :; }

# License
#
# This script is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This script is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this script; if not, write to the
# Free Software Foundation, Inc., 59 Temple Place, Suite 330,
# Boston, MA  02111-1307  USA

