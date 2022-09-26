#!/bin/bash

set -e
source /usr/local/etc/library.sh

install_template systemd/notify_push.service.sh /etc/systemd/system/notify_push.service
