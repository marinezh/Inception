NAME = Inception
COMPOSE_FILE := srcs/docker-compose.yml
COMPOSE      := docker compose -f $(COMPOSE_FILE)

# Host data paths (override via environment if needed)
MARIADB_DATA_PATH    ?= /home/mzhivoto/data/mariadb
WORDPRESS_DATA_PATH  ?= /home/mzhivoto/data/wordpress
DATA_DIRS            := $(MARIADB_DATA_PATH) $(WORDPRESS_DATA_PATH)

SUDO ?= sudo

# Define image names
MARIADB_IMAGE = mariadb:42
WORDPRESS_IMAGE = wordpress:42
NGINX_IMAGE = nginx:42


all: up

prepare-dirs:
	@mkdir -p $(DATA_DIRS)
	@if [ -d /home/mzhivoto/data ]; then \
		chown -R $(USER):$(USER) /home/mzhivoto/data 2>/dev/null || true; \
		chmod 755 /home/mzhivoto/data 2>/dev/null || true; \
	fi
	@chmod 755 $(DATA_DIRS) 2>/dev/null || true

build: prepare-dirs
	$(COMPOSE) build

up: prepare-dirs
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

clean: down
	$(COMPOSE) rm -f

fclean: down
	$(COMPOSE) down -v --remove-orphans
	rm -rf $(DATA_DIRS)
	@docker rmi -f $(MARIADB_IMAGE) $(WORDPRESS_IMAGE) $(NGINX_IMAGE) 2>/dev/null || true
	
re: fclean all

logs:
	$(COMPOSE) logs -f

.PHONY: all up build down clean fclean re logs prepare-dirs

