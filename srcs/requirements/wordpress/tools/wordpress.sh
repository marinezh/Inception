#!/bin/sh
# **************************************************************************** #
#                                                                              #
#    WordPress + PHP-FPM Entrypoint Script                                     #
#                                                                              #
#    Purpose:                                                                  #
#    1. Load credentials from Docker secrets                                  #
#    2. Download WordPress core files (if not present)                        #
#    3. Wait for MariaDB to be ready                                          #
#    4. Configure WordPress (wp-config.php)                                   #
#    5. Install WordPress (create admin, create second user)                  #
#    6. Start PHP-FPM in foreground mode (PID 1 for Docker)                   #
#                                                                              #
# **************************************************************************** #

set -eu

WP_PATH="/var/www/html"

# ============================================================================ #
#  Load Credentials from Docker Secrets                                        #
# ============================================================================ #

# Load secrets (must happen BEFORE required var checks)
if [ -n "${MYSQL_PASSWORD_FILE:-}" ] && [ -f "$MYSQL_PASSWORD_FILE" ]; then
  MYSQL_PASSWORD="$(cat "$MYSQL_PASSWORD_FILE")"
fi

if [ -n "${MYSQL_ROOT_PASSWORD_FILE:-}" ] && [ -f "$MYSQL_ROOT_PASSWORD_FILE" ]; then
  MYSQL_ROOT_PASSWORD="$(cat "$MYSQL_ROOT_PASSWORD_FILE")"
fi

# WordPress admin password via Docker secret
if [ -n "${WP_ADMIN_PASSWORD_FILE:-}" ] && [ -f "$WP_ADMIN_PASSWORD_FILE" ]; then
  WP_ADMIN_PASSWORD="$(cat "$WP_ADMIN_PASSWORD_FILE")"
fi

# WordPress editor user password via Docker secret
if [ -n "${WP_USER_PASSWORD_FILE:-}" ] && [ -f "$WP_USER_PASSWORD_FILE" ]; then
  WP_USER_PASSWORD="$(cat "$WP_USER_PASSWORD_FILE")"
fi

# ============================================================================ #
#  Validate Required Variables                                                 #
# ============================================================================ #

# ---- required vars ----
: "${MYSQL_HOST:?MYSQL_HOST is required}"
: "${MYSQL_DATABASE:?MYSQL_DATABASE is required}"
: "${MYSQL_USER:?MYSQL_USER is required}"

: "${WP_URL:?WP_URL is required}"
: "${WP_TITLE:?WP_TITLE is required}"
: "${WP_ADMIN_USER:?WP_ADMIN_USER is required}"
: "${WP_ADMIN_PASSWORD:?WP_ADMIN_PASSWORD (or WP_ADMIN_PASSWORD_FILE) is required}"
: "${WP_ADMIN_EMAIL:?WP_ADMIN_EMAIL is required}"

: "${MYSQL_PASSWORD:?MYSQL_PASSWORD (or MYSQL_PASSWORD_FILE) is required}"
MYSQL_PORT="${MYSQL_PORT:-3306}"
echo "[wordpress] DB target: ${MYSQL_HOST}:${MYSQL_PORT}"

export MYSQL_PASSWORD MYSQL_ROOT_PASSWORD WP_ADMIN_PASSWORD

# ============================================================================ #
#  Download WordPress Core Files                                               #
# ============================================================================ #

# ---- 1) Ensure WordPress files exist ----
# Download WordPress core only if not already present (idempotent)
if [ ! -f "$WP_PATH/index.php" ]; then
  echo "[wordpress] Downloading WordPress core..."
  mkdir -p "$WP_PATH"
  wget -q https://wordpress.org/latest.tar.gz -O /tmp/wp.tar.gz
  tar -xzf /tmp/wp.tar.gz -C /tmp
  mv /tmp/wordpress/* "$WP_PATH/"
  rm -rf /tmp/wordpress /tmp/wp.tar.gz
fi

# ============================================================================ #
#  Wait for MariaDB to be Ready                                                #
# ============================================================================ #

# ---- 2) Wait for MariaDB (bounded, evaluator-safe) ----
# Use mariadb-admin ping to check if database server is ready
# Max 90 seconds wait (prevents infinite loops during evaluation)
echo "[wordpress] Waiting for MariaDB server (max 90s)..."
i=0
until mariadb-admin ping -h"$MYSQL_HOST" -P"$MYSQL_PORT" --connect-timeout=2 --silent >/dev/null 2>&1

do
  i=$((i+1))
  [ "$i" -ge 90 ] && echo "[wordpress] ERROR: MariaDB server not reachable after 90s" && exit 1
  sleep 1
done
echo "[wordpress] MariaDB server is up."

# ============================================================================ #
#  Configure and Install WordPress                                             #
# ============================================================================ #


# ---- 3) Configure + install only once ----
# Only run if wp-config.php doesn't exist (prevents re-installation)
if [ ! -f "$WP_PATH/wp-config.php" ]; then
  echo "[wordpress] Creating wp-config.php..."
  # Use WP-CLI to generate wp-config.php with database credentials
  wp config create \
    --path="$WP_PATH" \
    --dbname="$MYSQL_DATABASE" \
    --dbuser="$MYSQL_USER" \
    --dbpass="$MYSQL_PASSWORD" \
    --dbhost="${MYSQL_HOST}:${MYSQL_PORT}" \
    --allow-root

  echo "[wordpress] Installing WordPress..."
  # Install WordPress (creates tables, admin user, sets site URL)
  wp core install \
    --path="$WP_PATH" \
    --url="$WP_URL" \
    --title="$WP_TITLE" \
    --admin_user="$WP_ADMIN_USER" \
    --admin_password="$WP_ADMIN_PASSWORD" \
    --admin_email="$WP_ADMIN_EMAIL" \
    --skip-email \
    --allow-root

  # Create second user (subject requirement: minimum 2 users)
  if ! wp user get editor --path="$WP_PATH" --allow-root >/dev/null 2>&1; then
    echo "[wordpress] Creating secondary WordPress user (editor)..."
    if [ -n "${WP_USER_PASSWORD:-}" ]; then
      wp user create \
        editor editor@example.com \
        --role=editor \
        --user_pass="$WP_USER_PASSWORD" \
        --path="$WP_PATH" \
        --allow-root
    else
      wp user create \
        editor editor@example.com \
        --role=editor \
        --path="$WP_PATH" \
        --allow-root
    fi
  fi

  echo "[wordpress] WordPress installation complete!"
fi

# ============================================================================ #
#  Start PHP-FPM                                                               #
# ============================================================================ #

# Set proper ownership for WordPress files (www-data user runs PHP-FPM)
chown -R www-data:www-data "$WP_PATH"

echo "[wordpress] Starting PHP-FPM..."
# Start PHP-FPM in foreground mode with explicit config file
# -F: Foreground mode (don't daemonize)
# -y: Specify config file path
# exec makes php-fpm82 PID 1 for proper Docker signal handling
exec php-fpm82 -F -y /etc/php82/php-fpm.conf
