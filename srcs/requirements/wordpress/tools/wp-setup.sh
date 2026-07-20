#!/bin/bash

# Wait until MariaDB is actually accepting connections.
# Without this, WordPress setup would run before the DB is ready and crash.
until mysqladmin ping -h "$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; do
    echo "Waiting for MariaDB..."
    sleep 2
done

echo "MariaDB is up!"

# Temporary — just to prove the wait logic works before adding the rest
exec php-fpm8.2 -F