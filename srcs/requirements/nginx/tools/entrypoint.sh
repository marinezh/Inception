#!/bin/sh
# **************************************************************************** #
#                                                                              #
#    NGINX Entrypoint Script                                                   #
#                                                                              #
#    Purpose:                                                                  #
#    1. Generate self-signed SSL certificate (TLSv1.2/1.3)                    #
#    2. Wait for WordPress files to be ready (shared volume)                  #
#    3. Start NGINX in foreground mode (PID 1 for Docker)                     #
#                                                                              #
# **************************************************************************** #

set -eu

# ============================================================================ #
#  SSL Certificate Generation                                                  #
# ============================================================================ #

# cert paths
CERT_DIR="/etc/nginx/ssl"
CRT="$CERT_DIR/server.crt"
KEY="$CERT_DIR/server.key"

mkdir -p "$CERT_DIR"

# Generate cert only once (persist via a volume if you want)
# Creates self-signed certificate using DOMAIN_NAME from .env
# -x509: Self-signed certificate | -nodes: No passphrase
# -newkey rsa:4096: 4096-bit RSA key | -days 365: Valid for 1 year
if [ ! -f "$CRT" ] || [ ! -f "$KEY" ]; then
  # Use your DOMAIN_NAME from .env (must be login.42.fr) :contentReference[oaicite:0]{index=0}
  openssl req -x509 -nodes -newkey rsa:4096 -days 365 \
    -keyout "$KEY" -out "$CRT" \
    -subj "/C=FI/ST=Uusimaa/L=Helsinki/O=42/OU=Inception/CN=${DOMAIN_NAME}"
fi

# ============================================================================ #
#  Wait for WordPress Files (Shared Volume)                                    #
# ============================================================================ #

# Wait for WordPress files to be present to avoid initial 403
TARGET="/var/www/html/index.php"
echo "[nginx] Waiting for WordPress files at $TARGET ..."

# Give volume mount a moment to stabilize (helps with reboot scenarios)
# Prevents race condition when containers auto-restart after VM reboot
sleep 5

# Check for WordPress files (max 120 seconds wait)
# Tests if file exists (-f) AND is not empty (-s)
i=0
for i in $(seq 1 60); do
  if [ -f "$TARGET" ] && [ -s "$TARGET" ]; then
    echo "[nginx] Found WordPress files."
    break
  fi
  sleep 2
done
[ "$i" -eq 60 ] && echo "[nginx] WARNING: WordPress files not found after 120s"

# ============================================================================ #
#  Start NGINX                                                                 #
# ============================================================================ #

# Start NGINX in foreground mode (daemon off)
# exec replaces shell with nginx (makes it PID 1 for proper signal handling)
exec nginx -g "daemon off;"

