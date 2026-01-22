# **************************************************************************** #
#                                                                              #
#    WordPress + PHP-FPM                                                       #
#                                                                              #
#    Base: Alpine 3.22 (penultimate stable - requirement)                      #
#    Purpose: WordPress CMS with PHP-FPM FastCGI processor                     #
#    Port: 9000 (FastCGI, internal only)                                      #
#                                                                              #
# **************************************************************************** #

FROM alpine:3.22

# Create www-data user/group if they don't already exist
# UID/GID 82 is standard for web servers
# || true allows script to continue if user already exists
RUN set -x \
    && addgroup -g 82 -S www-data 2>/dev/null || true \
    && adduser -u 82 -D -S -G www-data www-data 2>/dev/null || true

# Install PHP 8.2 and all required WordPress extensions
# php82-fpm: FastCGI Process Manager (communicates with NGINX)
# php82-mysqli: MySQL database connection
# php82-curl, php82-gd, etc.: WordPress required/recommended extensions
# mariadb-client: For database connectivity testing
# netcat-openbsd: Network diagnostics
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

# Create PHP-FPM runtime directories
# - /run/php: Socket/PID files
# - /var/log/php82: PHP error logs
RUN mkdir -p /run/php /var/log/php82 \
    && chown -R www-data:www-data /run/php /var/log/php82

# Install WP-CLI (WordPress Command Line Interface)
# Used in entrypoint to download WordPress core and configure installation
# Required by subject to automate WordPress setup
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Create symlinks for PHP binaries
# Alpine uses version-specific names (php82), but WP-CLI expects "php"
RUN ln -s /usr/bin/php82 /usr/bin/php \
    && ln -s /usr/sbin/php-fpm82 /usr/sbin/php-fpm

# Copy custom PHP-FPM pool configuration
# - Listens on TCP port 9000 (not Unix socket - for Docker networking)
# - Runs as www-data user
# - Process manager settings for performance
COPY conf/www.conf /etc/php82/php-fpm.d/www.conf

# Copy entrypoint script
# - Downloads WordPress if not present
# - Waits for MariaDB to be ready
# - Configures wp-config.php with database credentials
# - Installs WordPress (creates admin user, etc.)
# - Starts PHP-FPM in foreground mode
COPY tools/wordpress.sh /usr/local/bin/wordpress.sh

# Make entrypoint executable
RUN chmod +x /usr/local/bin/wordpress.sh

# Expose FastCGI port (only accessible within Docker network)
EXPOSE 9000

# Start WordPress setup and PHP-FPM via entrypoint
ENTRYPOINT ["/usr/local/bin/wordpress.sh"]
