#!/bin/bash

# this script runs at startup to provide an unique random passwords for each instance

## redis provisioning

REDISPASS="$( grep "^requirepass" /etc/redis/redis.conf | cut -f2 -d' ' )"

### IF redis password is the default one, generate a new one

[[ "$REDISPASS" == "default" ]] && {
  REDISPASS="$( openssl rand -base64 32 )"
  echo Provisioning Redis password
  sed -i -E "s|^requirepass .*|requirepass $REDISPASS|" /etc/redis/redis.conf
}

### If there exists already a configuration adjust the password
test -f /data/app/config/config.php && {
  echo Updating NextCloud config with Redis password $REDISPASS
  sed -i "s|'password'.*|'password' => '$REDISPASS',|" /data/app/config/config.php
}

## mariaDB provisioning

DBADMIN=ncadmin
DBPASSWD=$( grep password /root/.my.cnf | cut -d= -f2 )
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
EXIT
EOF
}

test -f /data/app/config/config.php && {
  echo Updating NextCloud config with MariaDB password $DBPASSWD
  sed -i "s|'dbpassword' =>.*|'dbpassword' => '$DBPASSWD',|" /data/app/config/config.php
}

exit 0
