1. Before starting evaluation

```bash
docker stop $(docker ps -qa)  \
docker rm $(docker ps -qa)  \
docker rmi -f $(docker images -qa)  \
docker volume rm $(docker volume ls -q) \
docker network rm $(docker network ls -q) 
```
2. Ensure no programm in background
```bash
docker inspect mariadb --format='{{.Config.Entrypoint}} {{.Config.Cmd}}'
docker inspect wordpress --format='{{.Config.Entrypoint}} {{.Config.Cmd}}'
docker inspect nginx --format='{{.Config.Entrypoint}} {{.Config.Cmd}}'
```
output:
[/usr/local/bin/entrypoint.sh] []
[/usr/local/bin/wordpress.sh] []
[/entrypoint.sh] []
[empty] it means script make make decision which script to run.

## Simple setup

### Ensure NGINX can be accessed by port 443 only
```bash
docker exec -it nginx grep -R "listen" /etc/nginx
```
or
```bash
docker compose -p srcs -f docker-compose.yml port nginx 80 || true
docker compose -p srcs -f docker-compose.yml port nginx 443 || true
```
### Check a SSL/TLS certificate
```bash
docker exec -it nginx sh -lc 'nginx -T 2>/dev/null | egrep -n "listen 443|ssl_certificate|ssl_certificate_key|ssl_protocols"'
```
## Check responce
```bash
curl -kI https://mzhivoto.42.fr
curl -kI http://mzhivoto.42.fr
```

## Docker Basics

1. I have this for each conatainer, it proves i build my own docker images
build:
	context: .requirements/mariadb
image:maria:42

use this command to see images and when they were created
```bash
docker images
```
## MAria BD
1. Enter to the sql database as a root user
```bash
docker exec -it mariadb mariadb -u root -p
```
or
```bash
docker exec -it mariadb mariadb -u wp_user -p
docker exec -it wordpress mariadb -h mariadb -u wp_user -p wordpress

```

2. Choose wordpress db
```sql
SHOW DATABASES;
USE wordpress;
```

3. What’s inside the database (all tables)
```sql
SHOW TABLES;
```
4. For each table: see what “data fields” exist		
	Pick a table and run:

```sql
DESCRIBE wp_posts;
DESCRIBE wp_comments;
DESCRIBE wp_users;
DESCRIBE wp_options;
```

5. Posts + pages (titles, status)
```sql
SELECT ID, post_type, post_status, post_title, post_date
FROM wp_posts
ORDER BY ID DESC
LIMIT 15;
```
or comments
```sql
SELECT comment_ID, comment_post_ID, comment_author, comment_approved, comment_date
FROM wp_comments
ORDER BY comment_ID DESC
LIMIT 15;
```
or users
```sql
SELECT ID, user_login, user_email, user_registered
FROM wp_users
ORDER BY ID ASC;
```
6. Check users in wordpress db (only as a root)
```sql
SELECT User, Host FROM mysql.user;
```
shoud be:
root
wp_user