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

##show containers status
```bash
 docker ps
or
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
docker ps --format "table {{.Names}}\t{{.Status}}"
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

## change host name:
1. sudo nano /etc/hosts
2. add test.42.fr save and close
3. nano srcs/.env 
  change  DOMAIN_NAME=test.42.fr
          WP_URL=https://test.42.fr

4. change nginx.conf -> server_name -> test.42.fr
5. make fclean, make
6. curl -Ik http://test.42.fr

## Debugging:
$ docker logs wordpress --tail=200

## check do we have wp-config.php
$ docker exec -it wordpress grep -n "DB_HOST" /var/www/html/wp-config.php

## check sertificate
$ docker exec nginx openssl x509 -in /etc/nginx/ssl/server.crt -noout -subject

-Expected Output:
subject=C=FI, ST=Uusimaa, L=Helsinki, O=42, OU=Inception, CN=mzhivoto.42.fr

# Check nginx configuration to see protocols
docker exec nginx grep "ssl_protocols" /etc/nginx/nginx.conf
-Expected Output:
ssl_protocols TLSv1.2 TLSv1.3;

1. Show Containers are Separate:
# WordPress has php-fpm, not nginx
docker exec wordpress which php-fpm8.2
docker exec wordpress which nginx  # Should fail

# MariaDB has only database, not nginx
docker exec mariadb which mysqld
docker exec mariadb which nginx  # Should fail

2. Show Volumes:
docker volume ls
# Should show:
# - srcs_mariadb_data
# - srcs_wp_files

docker volume inspect srcs_mariadb_data
docker volume inspect srcs_wp_files

3. Show Network:
docker network ls
# Should show: srcs_inception

docker network inspect srcs_inception
# Should show all 3 containers connected

4. Test Restart Policy:
# Kill a container and watch it restart
docker stop wordpress
docker ps  # Wait a few seconds, wordpress should be back

# Or kill the process
docker exec wordpress pkill php-fpm
docker ps  # Container should restart automatically

5. Check we donot have daemon (tail -f)
Проверка 1: Какой процесс PID 1?
$docker exec nginx ps aux

Хороший результат:
PID   COMMAND
1     nginx: master process nginx -g daemon off

Плохой результат:
PID   COMMAND
1     /bin/sh
7     nginx: master process

Проверка 2: Foreground режим?
$docker exec nginx ps aux | grep nginx
Должно быть daemon off в команде.

Проверка 3: Graceful остановка?
$time docker stop nginx

Конечно! Объясню концепцию демонов и Docker по-русски:

Что такое Демон (Daemon)?
Демон — это фоновый процесс в Unix/Linux системах, который:

Работает в фоне (background)
Отсоединяется от терминала
Обычно запускается при загрузке системы
Примеры: nginx, mysqld, sshd
Пример на обычном сервере:
Когда nginx запускается как демон:

Создаётся родительский процесс
Он создаёт дочерний процесс (fork)
Родитель умирает
Дочерний процесс продолжает работать в фоне
Ты получаешь контроль над терминалом обратно
Почему в Docker это НЕ работает?
Docker контейнер ≠ Виртуальная машина
Виртуальная машина	Docker контейнер
Полная ОС с init системой	Один главный процесс
Systemd/init управляет процессами	Процесс с PID 1 = главный
Много сервисов одновременно	Один сервис = один контейнер
Демоны работают нормально	Нужны foreground процессы
Проблема с демонами в Docker:
Результат: Контейнер сразу останавливается после запуска.

❌ Плохие практики (хаки):
Некоторые люди пытаются "обмануть" Docker:

Хак 1: tail -f
Что это делает:

Запускает nginx в фоне
Запускает tail -f чтобы держать контейнер живым
tail читает лог файл бесконечно
Почему это плохо:

Главный процесс = tail, а не nginx
Если nginx упадёт, контейнер продолжает работать (зомби)
Docker не знает о состоянии nginx
Нельзя нормально остановить
Хак 2: sleep infinity
Почему это плохо:

Главный процесс = sleep
Нет связи с реальным приложением
Контейнер висит даже если nginx умер
Хак 3: while true
Почему это плохо:

То же самое — главный процесс не nginx
✅ Правильный способ:
Запускать процесс в foreground режиме
Foreground (передний план) = процесс НЕ уходит в фон, блокирует терминал

Твой код — ПРАВИЛЬНЫЙ:
1. Nginx:
Что это значит:

daemon off = не уходить в фон, работать в foreground
exec = заменить текущий процесс (shell) на nginx
nginx становится PID 1 (главным процессом)
2. MariaDB:
Что это значит:

mysqld по умолчанию работает в foreground
exec делает его PID 1
3. PHP-FPM:
Что это значит:

-F = foreground режим (не демон)
exec делает его PID 1
Что такое exec?
Без exec:
Дерево процессов:

Проблема:

Главный процесс = shell, не nginx
docker stop отправляет сигнал SIGTERM shell'у
Shell может не передать сигнал nginx
Docker ждёт 10 секунд, потом убивает всё (SIGKILL)
С exec:
Дерево процессов:

Преимущества:

nginx напрямую получает сигналы
Graceful shutdown работает
Чистая остановка контейнера
Философия Docker:
НЕ надо:

❌ Запускать nginx + php-fpm + mysql в одном контейнере
❌ Использовать supervisord или systemd
❌ Пытаться сделать контейнер похожим на VM
НАДО:

✅ nginx в отдельном контейнере
✅ php-fpm в отдельном контейнере
✅ mysql в отдельном контейнере
✅ Связать их через docker network
Именно это ты и сделал! ✅

Как проверить что всё правильно:
Проверка 1: Какой процесс PID 1?
Хороший результат:

Плохой результат:

Проверка 2: Foreground режим?
Должно быть daemon off в команде.

Проверка 3: Graceful остановка?
Должно остановиться за ~1 секунду (graceful)
Не за 10 секунд (принудительное убийство)