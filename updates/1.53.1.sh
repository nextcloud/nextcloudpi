#!/usr/bin/env bash
set -e

source /usr/local/etc/library.sh

install_template apache2/ncp.conf.sh /etc/apache2/sites-available/ncp.conf --defaults
a2dissite nextcloud
mv /etc/apache2/sites-available/nextcloud.conf /etc/apache2/sites-available/001-nextcloud.conf
a2ensite 001-nextcloud
bash -c "sleep 2 && service apache2 reload" &>/dev/null &