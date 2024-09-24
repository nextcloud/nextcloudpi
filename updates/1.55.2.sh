#!/bin/bash
set -e

source /usr/local/etc/library.sh

run_app nc-autoupdate-nc

install_template "mysql/91-ncp.cnf.sh" "/etc/mysql/mariadb.conf.d/91-ncp.cnf"
service mariadb reload
