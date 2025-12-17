FROM debian:bookworm

RUN apt update && apt install -y \
    php-fpm php-mysql php-curl php-gd php-intl \
    php-mbstring php-soap php-xml php-xmlrpc \
    php-zip wget curl mariadb-client \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/php

RUN apt-get update && apt-get install -y --no-install-recommends iproute2 procps \
  && rm -rf /var/lib/apt/lists/*


COPY conf/wp-config.php /tmp/wp-config.php
COPY tools/wordpress.sh /usr/local/bin/wordpress.sh

RUN chmod +x /usr/local/bin/wordpress.sh

EXPOSE 9000

ENTRYPOINT ["wordpress.sh"]
CMD ["php-fpm8.2", "-F"]
