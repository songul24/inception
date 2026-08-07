#!/bin/bash


# --- Wait until MariaDB is actually accepting connections ---
until mysqladmin ping -h "$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; do
    echo "Waiting for MariaDB..."
    sleep 2
done
echo "MariaDB is up!"

# --- Only install WordPress the FIRST time (skip if already configured) ---
mkdir -p /var/www/wordpress
cd /var/www/wordpress || exit 1

if ! wp core is-installed --allow-root >/dev/null 2>&1; then
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
    # Install and activate the Redis Object Cache plugin
    wp plugin install redis-cache --activate --allow-root --path=/var/www/wordpress
    
    # Tell WordPress where Redis lives, then turn caching on
    wp config set WP_REDIS_HOST redis --allow-root --path=/var/www/wordpress
    wp redis enable --allow-root --path=/var/www/wordpress


    echo "Creating second (non-admin) user..."
    wp user create "$WP_USER" "$WP_USER_EMAIL" \
        --role=author \
        --user_pass="$WP_USER_PASSWORD" \
        --allow-root
else
    echo "WordPress already installed, skipping setup."
fi

# --- Start php-fpm in the foreground (real PID 1 process) ---
exec php-fpm8.2 -F