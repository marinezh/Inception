FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx openssl ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# Copy config + entrypoint
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/entrypoint.sh /entrypoint.sh

EXPOSE 443

ENTRYPOINT ["/entrypoint.sh"]
