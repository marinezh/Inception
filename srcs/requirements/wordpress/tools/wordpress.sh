#!/bin/sh
set -eu

WP_PATH="/var/www/html"

# ---- required vars ----
: "${MYSQL_HOST:?MYSQL_HOST is required}"
: "${MYSQL_DATABASE:?MYSQL_DATABASE is required}"
: "${MYSQL_USER:?MYSQL_USER is required}"

: "${WP_URL:?WP_URL is required}"
: "${WP_TITLE:?WP_TITLE is required}"
: "${WP_ADMIN_USER:?WP_ADMIN_USER is required}"
: "${WP_ADMIN_PASSWORD:?WP_ADMIN_PASSWORD is required}"
: "${WP_ADMIN_EMAIL:?WP_ADMIN_EMAIL is required}"

# ---- load secrets if provided ----
if [ -n "${MYSQL_PASSWORD_FILE:-}" ] && [ -f "$MYSQL_PASSWORD_FILE" ]; then
  MYSQL_PASSWORD="$(cat "$MYSQL_PASSWORD_FILE")"
fi
if [ -n "${MYSQL_ROOT_PASSWORD_FILE:-}" ] && [ -f "$MYSQL_ROOT_PASSWORD_FILE" ]; then
  MYSQL_ROOT_PASSWORD="$(cat "$MYSQL_ROOT_PASSWORD_FILE")"
fi
: "${MYSQL_PASSWORD:?MYSQL_PASSWORD (or MYSQL_PASSWORD_FILE) is required}"

export MYSQL_PASSWORD MYSQL_ROOT_PASSWORD

# ---- 1) Ensure WordPress files exist ----
if [ ! -f "$WP_PATH/index.php" ]; then
  echo "[wordpress] Downloading WordPress core..."
  mkdir -p "$WP_PATH"
  wget -q https://wordpress.org/latest.tar.gz -O /tmp/wp.tar.gz
  tar -xzf /tmp/wp.tar.gz -C /tmp
  mv /tmp/wordpress/* "$WP_PATH/"
  rm -rf /tmp/wordpress /tmp/wp.tar.gz
fi

# ---- 2) Wait for MariaDB (bounded, evaluator-safe) ----
echo "[wordpress] Waiting for MariaDB server (max 90s)..."
i=0
until mariadb-admin ping -h"$MYSQL_HOST" --connect-timeout=2 --silent >/dev/null 2>&1
do
  i=$((i+1))
  [ "$i" -ge 90 ] && echo "[wordpress] ERROR: MariaDB server not reachable after 90s" && exit 1
  sleep 1
done
echo "[wordpress] MariaDB server is up."


# ---- 3) Configure + install only once ----
if [ ! -f "$WP_PATH/wp-config.php" ]; then
  echo "[wordpress] Creating wp-config.php..."
  wp config create \
    --path="$WP_PATH" \
    --dbname="$MYSQL_DATABASE" \
    --dbuser="$MYSQL_USER" \
    --dbpass="$MYSQL_PASSWORD" \
    --dbhost="$MYSQL_HOST" \
    --allow-root

  echo "[wordpress] Installing WordPress..."
  wp core install \
    --path="$WP_PATH" \
    --url="$WP_URL" \
    --title="$WP_TITLE" \
    --admin_user="$WP_ADMIN_USER" \
    --admin_password="$WP_ADMIN_PASSWORD" \
    --admin_email="$WP_ADMIN_EMAIL" \
    --skip-email \
    --allow-root

  echo "[wordpress] WordPress installation complete!"
fi

chown -R www-data:www-data "$WP_PATH"

echo "[wordpress] Starting PHP-FPM..."
exec php-fpm8.2 -F
