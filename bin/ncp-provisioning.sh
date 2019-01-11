#!/bin/bash

# this script runs at startup to provide an unique random passwords for each instance

## redis provisioning

CFG=/var/www/nextcloud/config/config.php
REDISPASS="$( grep "^requirepass" /etc/redis/redis.conf | cut -f2 -d' ' )"

### IF redis password is the default one, generate a new one

[[ "$REDISPASS" == "default" ]] && {
  REDISPASS="$( openssl rand -base64 32 )"
  echo Provisioning Redis password
  sed -i -E "s|^requirepass .*|requirepass $REDISPASS|" /etc/redis/redis.conf
  [[ "$DOCKERBUILD" != 1 ]] && systemctl restart redis
}

### If there exists already a configuration adjust the password
[[ -f "$CFG" ]] && {
  echo "Updating NextCloud config with Redis password"
  sed -i "s|'password'.*|'password' => '$REDISPASS',|" "$CFG"
}

## mariaDB provisioning

DBADMIN=ncadmin
DBPASSWD=$( grep password /root/.my.cnf | sed 's|password=||' )

[[ "$DBPASSWD" == "default" ]] && {
  DBPASSWD=$( openssl rand -base64 32 )
  echo Provisioning MariaDB password
  echo -e "[client]\npassword=$DBPASSWD" > /root/.my.cnf
  chmod 600 /root/.my.cnf
  mysql <<EOF
GRANT USAGE ON *.* TO '$DBADMIN'@'localhost' IDENTIFIED BY '$DBPASSWD';
DROP USER '$DBADMIN'@'localhost';
CREATE USER '$DBADMIN'@'localhost' IDENTIFIED BY '$DBPASSWD';
GRANT ALL PRIVILEGES ON nextcloud.* TO $DBADMIN@localhost;
FLUSH PRIVILEGES;
EXIT
EOF
}

[[ -f "$CFG" ]] && {
  echo "Updating NextCloud config with MariaDB password"
  sed -i "s|'dbpassword' =>.*|'dbpassword' => '$DBPASSWD',|" "$CFG"
}

## nc.limits.sh (auto)adjustments: number of threads, memory limits...

source /usr/local/etc/library.sh
run_app nc-limits

## Check for interrupted upgrades and rollback
BKP="$( ls -1t /var/www/nextcloud-bkp_*.tar.gz 2>/dev/null | head -1 )"
[[ -f "$BKP" ]] && [[ "$( stat -c %U "$BKP" )" == "root" ]] && [[ "$( stat -c %a "$BKP" )" == 600 ]] && {
  echo "Detected interrupted upgrade. Restoring..."
  BKP_NEW="failed_$BKP"
  mv "$BKP" "$BKP_NEW"
  ncp-restore "$BKP_NEW" && rm "$BKP_NEW"
}

exit 0
