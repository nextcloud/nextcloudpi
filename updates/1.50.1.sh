#!/bin/bash

set -e
export NCPCFG=/usr/local/etc/ncp.cfg
source /usr/local/etc/library.sh

install_template systemd/notify_push.service.sh /etc/systemd/system/notify_push.service

bash -c "sleep 6; source /usr/local/etc/library.sh; clear_opcache; service php${PHPVER}-fpm reload" &>/dev/null &
