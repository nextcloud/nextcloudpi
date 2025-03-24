#!/usr/bin/env bash

set -eu -o pipefail

echo "Update DB row format ..."
mysql -u root -N nextcloud -e "SELECT CONCAT('ALTER TABLE \`', table_name, '\` row_format=DYNAMIC;') FROM information_schema.tables WHERE table_schema = 'nextcloud' AND engine = 'InnoDB' AND row_format != 'Dynamic';" | mysql -u root nextcloud
echo "Done."

