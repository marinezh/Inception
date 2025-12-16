FROM debian:12

RUN apt-get update && apt-get install -y --no-install-recommends \
    mariadb-server \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# MariaDB runtime dirs (Debian packages expect these)
RUN mkdir -p /run/mysqld /var/lib/mysql \
 && chown -R mysql:mysql /run/mysqld /var/lib/mysql

COPY conf/my.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
