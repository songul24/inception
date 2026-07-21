#!/bin/bash

# --- Read secrets from files instead of plain env vars ---
MYSQL_PASSWORD=$(cat "$MYSQL_PASSWORD_FILE")
WP_ADMIN_PASSWORD=$(cat "$WP_ADMIN_PASSWORD_FILE")

# --- Wait until MariaDB is actually accepting connections ---
until mysqladmin ping -h "$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; do
    echo "Waiting for MariaDB..."
    sleep 2
done
echo "MariaDB is up!"

# --- Only install WordPress the FIRST time (skip if already configured) ---
mkdir -p /var/www/wordpress
cd /var/www/wordpress || exit 1

if [ ! -f wp-config.php ]; then
    echo "Downloading WordPress..."
    wp core download --allow-root

    echo "Creating wp-config.php..."
    wp config create \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbhost="$MYSQL_HOST" \
        --allow-root

    echo "Installing WordPress..."
    wp core install \
        --url="$DOMAIN_NAME" \
        --title="Inception" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --allow-root
else
    echo "WordPress already installed, skipping setup."
fi

# --- Start php-fpm in the foreground (real PID 1 process) ---
exec php-fpm8.2 -F