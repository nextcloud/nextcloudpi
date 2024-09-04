#!/bin/bash

apt-get update
apt-get install -y --no-install-recommends logrotate

[ -f /etc/cron.d/ncp-previews-auto ] && mv /etc/cron.d/ncp-previews-auto /etc/cron.d/nc-previews-auto
