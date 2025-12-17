#!/bin/bash
set -e

WP_PATH=/var/www/html
PHP_VER="8.2"
WWW_CONF="/etc/php/${PHP_VER}/fpm/pool.d/www.conf"

# Wait for MariaDB to be ready
echo "Waiting for MariaDB..."
while ! mariadb -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SELECT 1" >/dev/null 2>&1; do
    sleep 2
done
echo "MariaDB is ready!"

# -----------------------------
# 1) Install/config WordPress (first run only)
# -----------------------------
if [ ! -f "$WP_PATH/wp-config.php" ]; then
    echo "Downloading WordPress..."
    cd "$WP_PATH"
    wget https://wordpress.org/latest.tar.gz -O /tmp/wp.tar.gz
    tar -xzf /tmp/wp.tar.gz -C /tmp
    mv /tmp/wordpress/* "$WP_PATH/"
    rm -rf /tmp/wordpress /tmp/wp.tar.gz

    echo "Creating wp-config.php with WP-CLI..."
    wp config create \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbhost="$MYSQL_HOST" \
        --allow-root

    echo "Installing WordPress..."
    wp core install \
        --url="$WP_URL" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --allow-root
    
    echo "WordPress installation complete!"
fi

# -----------------------------
# 2) Start php-fpm in foreground (PID 1)
# -----------------------------
echo "Starting PHP-FPM..."
exec php-fpm8.2 -F

