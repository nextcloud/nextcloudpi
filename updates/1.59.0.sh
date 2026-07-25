#!/usr/bin/env bash

set -euo pipefail

echo "Configuring serverid ..."
old_id="$(ncc config:system:get serverid)"
[[ "$old_id" -lt 512 ]] || ncc config:system:set serverid --value="$((RANDOM % 512))" --type=integer
