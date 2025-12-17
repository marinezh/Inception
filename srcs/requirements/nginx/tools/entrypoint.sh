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

exec nginx -g "daemon off;"
