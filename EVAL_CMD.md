1. Before starting evaluation

```bash
docker stop $(docker ps -qa) && \
docker rm $(docker ps -qa) && \
docker rmi -f $(docker images -qa) && \
docker volume rm $(docker volume ls -q) && \
docker network rm $(docker network ls -q) 2>/dev/null
```
2. ```bash
docker inspect mariadb --format='{{.Config.Entrypoint}} {{.Config.Cmd}}'
docker inspect wordpress --format='{{.Config.Entrypoint}} {{.Config.Cmd}}'
docker inspect nginx --format='{{.Config.Entrypoint}} {{.Config.Cmd}}'
```