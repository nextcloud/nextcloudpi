#!/bin/bash

set -e
export NCPCFG=/usr/local/etc/ncp.cfg
source /usr/local/etc/library.sh


service "php${PHPVER}-fpm" stop
clear_opcache
service "php${PHPVER}-fpm" start
