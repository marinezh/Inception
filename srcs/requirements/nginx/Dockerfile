# **************************************************************************** #
#                                                                              #
#    NGINX - Web Server with TLS/SSL                                           #
#                                                                              #
#    Base: Alpine 3.22 (penultimate stable - requirement)                      #
#    Purpose: Reverse proxy, serves WordPress via HTTPS only                   #
#    Port: 443 (TLSv1.2, TLSv1.3)                                              #
#                                                                              #
# **************************************************************************** #

FROM alpine:3.22

# Install NGINX and SSL tools
# - nginx: Web server
# - openssl: Generate self-signed certificates
# - ca-certificates: SSL certificate verification
# - netcat-openbsd: Network diagnostics (can check if services are up)
RUN apk add --no-cache \
    nginx \
    openssl \
    ca-certificates \
    netcat-openbsd

# Remove default NGINX config to avoid conflicts
RUN rm -f /etc/nginx/http.d/default.conf

# Copy custom NGINX configuration
# - Listens on port 443 (HTTPS only - required by subject)
# - Configured to proxy requests to WordPress PHP-FPM on port 9000
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Copy entrypoint script
# - Generates self-signed SSL certificate using DOMAIN_NAME from .env
# - Waits for WordPress files to be ready before starting
COPY tools/entrypoint.sh /entrypoint.sh

# Make entrypoint executable
RUN chmod +x /entrypoint.sh

# Expose HTTPS port (443 only - HTTP not allowed per subject)
EXPOSE 443

# Start NGINX in foreground mode (not as daemon - Docker requirement)
ENTRYPOINT ["/entrypoint.sh"]
