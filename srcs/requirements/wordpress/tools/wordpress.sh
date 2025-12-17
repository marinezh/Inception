#!/bin/bash
set -e

WP_PATH=/var/www/html
PHP_VER="8.2"
WWW_CONF="/etc/php/${PHP_VER}/fpm/pool.d/www.conf"

# -----------------------------
# 1) Install/config WordPress (first run only)
# -----------------------------
if [ ! -f "$WP_PATH/wp-config.php" ]; then
    echo "Downloading WordPress..."
    wget https://wordpress.org/latest.tar.gz -O /tmp/wp.tar.gz
    tar -xzf /tmp/wp.tar.gz -C /tmp
    mv /tmp/wordpress/* "$WP_PATH"

    echo "Configuring WordPress..."
    cp /tmp/wp-config.php "$WP_PATH/wp-config.php"

    sed -i "s/database_name_here/$MYSQL_DATABASE/g" "$WP_PATH/wp-config.php"
    sed -i "s/username_here/$MYSQL_USER/g" "$WP_PATH/wp-config.php"
    sed -i "s/password_here/$MYSQL_PASSWORD/g" "$WP_PATH/wp-config.php"
    sed -i "s/localhost/$MYSQL_HOST/g" "$WP_PATH/wp-config.php"
fi

# -----------------------------
# 2) Make php-fpm reachable from NGINX container
#    (switch from unix socket to TCP 9000)
# -----------------------------
WWW_CONF="/etc/php/8.2/fpm/pool.d/www.conf"

if [ -f "$WWW_CONF" ]; then
    # Listen on TCP for other containers
    sed -i 's|^listen = .*|listen = 0.0.0.0:9000|' "$WWW_CONF"

    # Remove any allowed_clients restriction (and duplicates)
    sed -i '/^listen\.allowed_clients\s*=/d' "$WWW_CONF"
fi

mkdir -p /run/php

# -----------------------------
# 3) Start php-fpm in foreground (PID 1)
# -----------------------------
exec php-fpm8.2 -F

