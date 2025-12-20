#!/bin/sh
set -eu

# Load secrets
if [ -n "${MYSQL_PASSWORD_FILE:-}" ] && [ -f "$MYSQL_PASSWORD_FILE" ]; then
  MYSQL_PASSWORD="$(cat "$MYSQL_PASSWORD_FILE")"
fi
if [ -n "${MYSQL_ROOT_PASSWORD_FILE:-}" ] && [ -f "$MYSQL_ROOT_PASSWORD_FILE" ]; then
  MYSQL_ROOT_PASSWORD="$(cat "$MYSQL_ROOT_PASSWORD_FILE")"
fi

: "${MYSQL_DATABASE:?MYSQL_DATABASE is required}"
: "${MYSQL_USER:?MYSQL_USER is required}"
: "${MYSQL_PASSWORD:?MYSQL_PASSWORD is required}"
: "${MYSQL_ROOT_PASSWORD:?MYSQL_ROOT_PASSWORD is required}"

mkdir -p /run/mysqld /var/lib/mysql
chown -R mysql:mysql /run/mysqld /var/lib/mysql

INIT_MARKER="/var/lib/mysql/.inception_init_done"

if [ ! -f "$INIT_MARKER" ]; then
  echo "[mariadb] Initializing database..."
  mariadb-install-db --user=mysql --datadir=/var/lib/mysql >/dev/null

  echo "[mariadb] Starting temp server..."
  mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking --socket=/run/mysqld/mysqld.sock &
  pid="$!"

  i=0
  while ! mariadb-admin --socket=/run/mysqld/mysqld.sock ping >/dev/null 2>&1; do
    i=$((i+1))
    [ "$i" -ge 60 ] && echo "[mariadb] ERROR: init timeout" && exit 1
    sleep 1
  done

  echo "[mariadb] Creating users/database..."
  mariadb --socket=/run/mysqld/mysqld.sock <<-SQL
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
    CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
    FLUSH PRIVILEGES;
SQL

  mariadb-admin --socket=/run/mysqld/mysqld.sock -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
  wait "$pid" 2>/dev/null || true

  touch "$INIT_MARKER"
  chown mysql:mysql "$INIT_MARKER"
  echo "[mariadb] Init complete."
fi

echo "[mariadb] Starting MariaDB server..."
exec mysqld --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0
