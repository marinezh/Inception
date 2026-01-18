## Ensure that NGINX can be accessed by port 443 only
```bash
docker exec -it nginx grep -R "listen" /etc/nginx
```

## Check responce
```bash
curl -vkI https://mzhivoto.42.fr
curl -vkI http://mzhivoto.42.fr
```

## Check a SSL/TLS certificate
```bash
docker exec -it nginx sh -lc 'nginx -T 2>/dev/null | egrep -n "listen 443|ssl_certificate|ssl_certificate_key|ssl_protocols"'

echo | openssl s_client -connect mzhivoto.42.fr:443 -servername mzhivoto.42.fr
```

## NGINX with SSL/TLS

## Using the 'docker-compose ps' command, ensure that the container was created (using the flag '-p' is authorized if necessary)
```bash
docker compose -p srcs -f docker-compose.yml ps
```

## Check access the service via port 80 and 443
```bash
docker compose -p srcs -f docker-compose.yml port nginx 80 || true
docker compose -p srcs -f docker-compose.yml port nginx 443 || true
```

## WordPress
```bash
docker volume ls
docker volume inspect srcs_wordpress
docker volume inspect srcs_mariadb
```

output
```bash
"Options": {
  "device": "/home/mzhivoto/data/wordpress",
  "o": "bind",
  "type": "none"
}
```
or 
```bash
"Mountpoint": "/home/mzhivoto/data/wordpress"
```
inter to admin panel
```bash
https://mzhivoto.42.fr/wp-login
```

## MariaDB
```bash
docker exec -it mariadb sh
```
```bash
mariadb -u root
# or
mysql -u root
```

```bash
mariadb -u root -p"$(cat /run/secrets/db_root_password)"
```
```bash
mariadb -u root -p
# paste the content of /run/secrets/db_root_password when prompted

mariadb -u "$MYSQL_USER" -p"$(cat /run/secrets/db_password)" "$MYSQL_DATABASE"
```
```bash
env | grep -E 'MYSQL_(USER|DATABASE)'
```
```sql
SHOW DATABASES;
USE <your_db_name>;
SHOW TABLES;
SELECT COUNT(*) FROM wp_users;
```

## changing the ports for evaluation

- change 443 to 8443 everythewe is settings 
then
```bash
curl -Ik https://mzhivoto.42.fr:8443
```

URL	Port used
http://example.com	80
https://example.com	443
https://example.com:8443	8443

Protocols have default ports unless overridden.
Yep — this is a good sign ✅ Your nginx on 8443 works, and WordPress is responding.

What the response means
HTTP/2 301 = redirect
x-redirect-by: WordPress = WordPress itself decided to redirect
location: https://mzhivoto.42.fr/ = it redirects to the canonical site URL without the port
Why it redirects back to 443 (and then fails)
WordPress has a “site URL” stored in DB (or defined in config) like:

https://mzhivoto.42.fr

and it does not include :8443
So when you access via :8443, WordPress says:
“Nope, the real site is https://mzhivoto.42.fr/”
and sends you to default HTTPS port 443.
Since you changed nginx away from 443 → you can’t follow the redirect.


## Debugging:
$ docker logs wordpress --tail=200

## check do we have wp-config.php
$ docker exec -it wordpress grep -n "DB_HOST" /var/www/html/wp-config.php

## check sertificate
$ docker exec nginx openssl x509 -in /etc/nginx/ssl/server.crt -noout -subject

-Expected Output:
subject=C=FI, ST=Uusimaa, L=Helsinki, O=42, OU=Inception, CN=mzhivoto.42.fr