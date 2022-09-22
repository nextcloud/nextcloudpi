#!/bin/bash

set -e

source /usr/local/etc/library.sh


clear_opcache
service "php${PHPVER}-fpm" restart
