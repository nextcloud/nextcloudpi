#!/bin/bash

# Update modsecurity config file only if user is already in buster and 
# modsecurity is used.
# https://github.com/nextcloud/nextcloudpi/issues/959
is_active_app modsecurity && run_app modsecurity

exit 0
