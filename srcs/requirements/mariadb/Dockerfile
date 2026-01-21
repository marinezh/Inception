# **************************************************************************** #
#                                                                              #
#    MariaDB - Database Server                                                 #
#                                                                              #
#    Base: Alpine 3.22 (penultimate stable - requirement)                      #
#    Purpose: MySQL-compatible database for WordPress                          #
#    Port: 3306 (internal only, not exposed to host)                          #
#                                                                              #
# **************************************************************************** #

FROM alpine:3.22

# Install MariaDB server and client
# - mariadb: Database server
# - mariadb-client: Client tools (mysql, mysqladmin for healthcheck)
RUN apk add --no-cache \
    mariadb \
    mariadb-client

# Create MariaDB runtime directories
# - /run/mysqld: Socket file location
# - /var/lib/mysql: Database data storage
# Set ownership to mysql user (created by mariadb package)
RUN mkdir -p /run/mysqld /var/lib/mysql \
 && chown -R mysql:mysql /run/mysqld /var/lib/mysql

# Copy custom MariaDB configuration
# - Configured to listen on all interfaces (0.0.0.0)
# - Sets character encoding, buffer sizes, etc.
COPY conf/my.cnf /etc/my.cnf.d/mariadb-server.cnf

# Copy entrypoint script
# - Initializes database on first run
# - Creates database, users with passwords from Docker secrets
# - Starts MariaDB in foreground mode
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

# Make entrypoint executable
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose MySQL port (only accessible within Docker network - not published)
#  Port: 3306 (internal only, not exposed to host)
EXPOSE 3306

# Start MariaDB via entrypoint script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
