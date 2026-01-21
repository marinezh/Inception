#!/bin/sh
# **************************************************************************** #
#                                                                              #
#    MariaDB Entrypoint Script                                                 #
#                                                                              #
#    Purpose:                                                                  #
#    1. Load database credentials from Docker secrets                          #
#    2. Initialize database on first run (create DB, users, grants)            #
#    3. Start MariaDB server in foreground mode (PID 1 for Docker)             #
#                                                                              #
# **************************************************************************** #

set -eu

# ============================================================================ #
#  Load Database Credentials from Docker Secrets                               #
# ============================================================================ #

# Load secrets (read from /run/secrets/ mounted by Docker)
# Docker secrets are more secure than environment variables
if [ -n "${MYSQL_PASSWORD_FILE:-}" ] && [ -f "$MYSQL_PASSWORD_FILE" ]; then
  MYSQL_PASSWORD="$(cat "$MYSQL_PASSWORD_FILE")"
fi
if [ -n "${MYSQL_ROOT_PASSWORD_FILE:-}" ] && [ -f "$MYSQL_ROOT_PASSWORD_FILE" ]; then
  MYSQL_ROOT_PASSWORD="$(cat "$MYSQL_ROOT_PASSWORD_FILE")"
fi

# Validate required variables are set
: "${MYSQL_DATABASE:?MYSQL_DATABASE is required}"
: "${MYSQL_USER:?MYSQL_USER is required}"
: "${MYSQL_PASSWORD:?MYSQL_PASSWORD is required}"
: "${MYSQL_ROOT_PASSWORD:?MYSQL_ROOT_PASSWORD is required}"

# ============================================================================ #
#  Prepare Runtime Directories                                                 #
# ============================================================================ #

mkdir -p /run/mysqld /var/lib/mysql
chown -R mysql:mysql /run/mysqld /var/lib/mysql

# ============================================================================ #
#  Database Initialization (First Run Only)                                    #
# ============================================================================ #

# Marker file to prevent re-initialization on container restart
INIT_MARKER="/var/lib/mysql/.inception_init_done"

# Only initialize if marker file doesn't exist (prevents re-init on restart)
if [ ! -f "$INIT_MARKER" ]; then
  echo "[mariadb] Initializing database..."
  # Create system tables and initial database structure
  mariadb-install-db --user=mysql --datadir=/var/lib/mysql >/dev/null

  echo "[mariadb] Starting temp server..."
  # Start temporary server without networking (socket-only for setup)
  mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking --socket=/run/mysqld/mysqld.sock &
  pid="$!"

  # Wait for temporary server to be ready (max 60 seconds)
  i=0
  while ! mariadb-admin --socket=/run/mysqld/mysqld.sock ping >/dev/null 2>&1; do
    i=$((i+1))
    [ "$i" -ge 60 ] && echo "[mariadb] ERROR: init timeout" && exit 1
    sleep 1
  done

  echo "[mariadb] Creating users/database..."
  # Execute SQL commands to set up database and users
  # - Set root password
  # - Create WordPress database
  # - Create WordPress user with remote access (%)
  # - Grant all privileges on WordPress database to WordPress user
  mariadb --socket=/run/mysqld/mysqld.sock <<-SQL
   ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
   CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
   CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
   CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';
   GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
   GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'localhost';
   FLUSH PRIVILEGES;
SQL

  # Shutdown temporary server gracefully
  mariadb-admin --socket=/run/mysqld/mysqld.sock -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
  wait "$pid" 2>/dev/null || true

  # Create marker file to indicate initialization is complete
  touch "$INIT_MARKER"
  chown mysql:mysql "$INIT_MARKER"
  echo "[mariadb] Init complete."
fi

# ============================================================================ #
#  Start MariaDB Server                                                        #
# ============================================================================ #

echo "[mariadb] Starting MariaDB server..."
# Start MariaDB in foreground mode, listening on all interfaces
# exec makes mysqld PID 1 for proper Docker signal handling
exec mysqld --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0
