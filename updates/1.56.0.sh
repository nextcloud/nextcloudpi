#!/usr/bin/env bash

if { ncc app_api:daemon:list || true; } 2> /dev/null | grep 'No registered daemon configs.' > /dev/null 2>&1
then
  ncc app:disable app_api
fi

exit 0