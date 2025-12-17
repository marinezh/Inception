FROM debian:bookworm

RUN apt update && apt install -y \
    php-fpm php-mysql php-curl php-gd php-intl \
    php-mbstring php-soap php-xml php-xmlrpc \
    php-zip wget curl mariadb-client \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/php /var/log/php-fpm

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Copy PHP-FPM pool configuration
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

COPY tools/wordpress.sh /usr/local/bin/wordpress.sh

RUN chmod +x /usr/local/bin/wordpress.sh

EXPOSE 9000

ENTRYPOINT ["wordpress.sh"]
CMD ["php-fpm8.2", "-F"]
