#!/bin/bash

# Optimize MariaDB
#

configure()
{
  echo -ne "begin of MariaDB Optimization..."
  mariadb-check --optimize --all-databases >/dev/null
  echo "Completed"
}

install() { :; }
