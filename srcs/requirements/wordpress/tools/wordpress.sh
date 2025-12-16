#!/bin/bash
set -e

WP_PATH=/var/www/html

if [ ! -f "$WP_PATH/wp-config.php" ]; then
    echo "Downloading WordPress..."
    wget https://wordpress.org/latest.tar.gz -O /tmp/wp.tar.gz
    tar -xzf /tmp/wp.tar.gz -C /tmp
    mv /tmp/wordpress/* $WP_PATH

    echo "Configuring WordPress..."
    cp /tmp/wp-config.php $WP_PATH/wp-config.php

    sed -i "s/database_name_here/$MYSQL_DATABASE/g" $WP_PATH/wp-config.php
    sed -i "s/username_here/$MYSQL_USER/g" $WP_PATH/wp-config.php
    sed -i "s/password_here/$MYSQL_PASSWORD/g" $WP_PATH/wp-config.php
    sed -i "s/localhost/$MYSQL_HOST/g" $WP_PATH/wp-config.php
fi

exec "$@"
