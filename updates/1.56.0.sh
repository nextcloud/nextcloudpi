#!/usr/bin/env bash

if ncc app_api:daemon:list | grep 'No registered daemon configs.' > /dev/null 2>&1
then
  ncc app:disable app_api
fi

exit 0