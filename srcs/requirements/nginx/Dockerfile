FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx openssl ca-certificates netcat-openbsd \
  && rm -rf /var/lib/apt/lists/*

RUN rm -f /etc/nginx/sites-enabled/default /etc/nginx/sites-available/default /etc/nginx/conf.d/default.conf


# Copy config + entrypoint
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/entrypoint.sh /entrypoint.sh

EXPOSE 443

ENTRYPOINT ["/entrypoint.sh"]
