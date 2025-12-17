## MARIADB SETTING UP

## WORDPRESS SETTING UP

### 1️⃣ Base image choice
```dockerfile
FROM debian:bookworm
```
Why?

Subject allows Debian or Alpine
Debian:
stable
easy PHP packages
predictable for evaluation

### 2️⃣ Installed required packages
```bash
php-fpm
php-mysql
php-xml
php-mbstring
php-curl
php-gd
wget
mariadb-client
```
### 3️⃣ PHP-FPM runs as PID 1 (important!)
```dockerfile
CMD ["php-fpm8.2", "-F"]
```
Why?

-F → foreground
php-fpm becomes PID 1
No fake loops (tail -f, sleep infinity)
✔ Fully compliant with Docker best practices

### 4️⃣ Entry script (wordpress.sh)
```bash
if wp-config.php does NOT exist:
    download WordPress
    extract files
    copy wp-config template
    inject env variables
```
Why this pattern?
Safe on restarts
Idempotent
No infinite loops
No re-download after reboot
✔ Correct container lifecycle behavior

### 5️⃣ Environment variables (.env)
```env
MYSQL_HOST=mariadb
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
MYSQL_PASSWORD=****
```
Why?

No secrets in Dockerfiles
Easy to change
Subject requirement
✔ Secure

### 6️⃣ wp-config.php template
```php
define('DB_NAME', 'database_name_here');
define('DB_USER', 'username_here');
define('DB_PASSWORD', 'password_here');
define('DB_HOST', 'localhost');
```
Why?

Keeps secrets out of Git
Clean separation of config vs runtime
✔ Best practice
✔ Matches subject rules

### 7️⃣ Persistent storage (volumes)
```yaml
volumes:
  - wp_files:/var/www/html
```
## NGINX SETTING UP

### Make sh script executable
```bash
chmod +x srcs/requirements/nginx/tools/entrypoint.sh
```
build and start everything:
```bash
docker-compose up -d --build
```
check:
```bash
docker ps
docker logs nginx
```
Rebuild and restart nginx
```bash
docker-compose up -d --build nginx
```