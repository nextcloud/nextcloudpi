#!/bin/bash

set -e

source /usr/local/etc/library.sh


install_template "php/opcache.ini.sh" "/etc/php/${PHPVER}/mods-available/opcache.ini"
