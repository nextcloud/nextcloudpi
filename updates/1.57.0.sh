#!/usr/bin/env bash

set -eu

ncc config:system:set serverid --value="$((RANDOM % 1024))" --type=integer