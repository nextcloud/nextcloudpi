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
EXIT
EOF
}

[[ -f "$CFG" ]] && {
  echo "Updating NextCloud config with MariaDB password"
  sed -i "s|'dbpassword' =>.*|'dbpassword' => '$DBPASSWD',|" "$CFG"
}

## CPU core adjustment

CURRENT_THREADS=$( grep "^pm.max_children" /etc/php/7.0/fpm/pool.d/www.conf | awk '{ print $3 }' )

CFG=/usr/local/etc/nextcloudpi-config.d/nc-limits.sh
PHPTHREADS=0
[[ -f "$CFG" ]] && PHPTHREADS=$( grep "^PHPTHREADS_" "$CFG"  | cut -d= -f2 )

[[ $PHPTHREADS -eq 0 ]] && PHPTHREADS=$( nproc )

[[ $PHPTHREADS -ne $CURRENT_THREADS ]] && {

  echo "PHP threads set to $PHPTHREADS"

  sed -i "s|pm.max_children =.*|pm.max_children = $PHPTHREADS|"           /etc/php/7.0/fpm/pool.d/www.conf
  sed -i "s|pm.max_spare_servers =.*|pm.max_spare_servers = $PHPTHREADS|" /etc/php/7.0/fpm/pool.d/www.conf
  sed -i "s|pm.start_servers =.*|pm.start_servers = $PHPTHREADS|"         /etc/php/7.0/fpm/pool.d/www.conf

  # need to restart php
  bash -c " sleep 3
            systemctl stop php7.0-fpm
            systemctl stop mysqld
            sleep 0.5
            systemctl start php7.0-fpm
            systemctl start mysqld
            " &>/dev/null &
}

exit 0
