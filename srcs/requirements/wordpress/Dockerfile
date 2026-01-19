FROM alpine:3.20

# Create www-data user/group if they don't exist
RUN set -x \
    && addgroup -g 82 -S www-data 2>/dev/null || true \
    && adduser -u 82 -D -S -G www-data www-data 2>/dev/null || true

RUN apk add --no-cache \
    php82 \
    php82-fpm \
    php82-mysqli \
    php82-curl \
    php82-gd \
    php82-intl \
    php82-mbstring \
    php82-soap \
    php82-xml \
    php82-zip \
    php82-phar \
    php82-openssl \
    php82-json \
    php82-dom \
    php82-xmlwriter \
    php82-session \
    php82-tokenizer \
    php82-ctype \
    php82-fileinfo \
    php82-iconv \
    php82-simplexml \
    php82-xmlreader \
    wget \
    curl \
    mariadb-client \
    netcat-openbsd

RUN mkdir -p /run/php /var/log/php82 \
    && chown -R www-data:www-data /run/php /var/log/php82

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Create symlink for PHP-FPM (Alpine uses php-fpm82)
RUN ln -s /usr/sbin/php-fpm82 /usr/sbin/php-fpm

# Copy PHP-FPM pool configuration
COPY conf/www.conf /etc/php82/php-fpm.d/www.conf

COPY tools/wordpress.sh /usr/local/bin/wordpress.sh

RUN chmod +x /usr/local/bin/wordpress.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/wordpress.sh"]
