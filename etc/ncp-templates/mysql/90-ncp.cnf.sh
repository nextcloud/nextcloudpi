# configure MariaDB (UTF8 4 byte support)
cat > /etc/mysql/mariadb.conf.d/90-ncp.cnf <<EOF
[mysqld]
datadir = /var/lib/mysql
EOF