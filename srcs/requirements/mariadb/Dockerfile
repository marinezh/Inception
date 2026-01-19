FROM alpine:3.20

RUN apk add --no-cache \
    mariadb \
    mariadb-client

# MariaDB runtime dirs
RUN mkdir -p /run/mysqld /var/lib/mysql \
 && chown -R mysql:mysql /run/mysqld /var/lib/mysql

COPY conf/my.cnf /etc/my.cnf.d/mariadb-server.cnf
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
