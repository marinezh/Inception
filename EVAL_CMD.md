1. Before starting evaluation

```bash
docker stop $(docker ps -qa) && \
docker rm $(docker ps -qa) && \
docker rmi -f $(docker images -qa) && \
docker volume rm $(docker volume ls -q) && \
docker network rm $(docker network ls -q) 2>/dev/null
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
