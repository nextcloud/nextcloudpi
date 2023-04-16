#!/usr/bin/env bash

source /usr/local/etc/library.sh

install_template "mysql/91-ncp.cnf.sh" "/etc/mysql/mariadb.conf.d/91-ncp.cnf"
service mariadb restart
