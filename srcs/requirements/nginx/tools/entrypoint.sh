#!/bin/sh
set -eu

# cert paths
CERT_DIR="/etc/nginx/ssl"
CRT="$CERT_DIR/server.crt"
KEY="$CERT_DIR/server.key"

mkdir -p "$CERT_DIR"

# Generate cert only once (persist via a volume if you want)
if [ ! -f "$CRT" ] || [ ! -f "$KEY" ]; then
  # Use your DOMAIN_NAME from .env (must be login.42.fr) :contentReference[oaicite:1]{index=1}
  openssl req -x509 -nodes -newkey rsa:4096 -days 365 \
    -keyout "$KEY" -out "$CRT" \
    -subj "/C=FI/ST=Uusimaa/L=Helsinki/O=42/OU=Inception/CN=${DOMAIN_NAME}"
fi
# Wait for WordPress files to be present to avoid initial 403
TARGET="/var/www/html/index.php"
echo "[nginx] Waiting for WordPress files at $TARGET ..."
for i in $(seq 1 60); do
  if [ -f "$TARGET" ]; then
    echo "[nginx] Found WordPress files."
    break
  fi
  sleep 2
done

exec nginx -g "daemon off;"
