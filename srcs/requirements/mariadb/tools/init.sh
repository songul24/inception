#!/bin/bash

# Read secrets from files (mounted via Docker secrets/_FILE pattern)
MYSQL_PASSWORD=$(cat "$MYSQL_PASSWORD_FILE")
MYSQL_ROOT_PASSWORD=$(cat "$MYSQL_ROOT_PASSWORD_FILE")

# Create the socket/runtime directory MariaDB needs before it can start
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# Only initialize the data directory if it hasn't been done before
if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Run SQL commands in bootstrap mode to create DB and users
mysqld --user=mysql --bootstrap <<EOF
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
FLUSH PRIVILEGES;
EOF

# Start MariaDB as PID 1 in foreground so it receives signals correctly
exec mysqld --user=mysql
