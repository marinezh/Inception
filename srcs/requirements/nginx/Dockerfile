FROM alpine:3.19

RUN apk add --no-cache \
    nginx \
    openssl \
    ca-certificates \
    netcat-openbsd

RUN rm -f /etc/nginx/http.d/default.conf

# Copy config + entrypoint
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 443

ENTRYPOINT ["/entrypoint.sh"]
