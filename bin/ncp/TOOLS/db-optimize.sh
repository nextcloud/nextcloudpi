#!/bin/bash

# Optimize MariaDB
#

configure()
{
  echo -ne "begin of MariaDB Optimization..."
  mariadb-check -u root --optimize --all-databases 
  echo "Completed"
}

install() { :; }
