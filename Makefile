COMPOSE_FILE := srcs/docker-compose.yml
COMPOSE      := docker compose -f $(COMPOSE_FILE)

# Host data paths (override via environment if needed)
MARIADB_DATA_PATH    ?= /home/mzhivoto/data/mariadb
WORDPRESS_DATA_PATH  ?= /home/mzhivoto/data/wordpress
DATA_DIRS            := $(MARIADB_DATA_PATH) $(WORDPRESS_DATA_PATH)

# Use sudo for operations that may require elevated permissions
SUDO ?= sudo

.PHONY: all up build down clean fclean re logs prepare-dirs

all: up

prepare-dirs:
	mkdir -p $(DATA_DIRS)
	$(SUDO) chown -R mzhivoto:mzhivoto /home/mzhivoto/data
	$(SUDO) chmod 755 /home/mzhivoto/data
	$(SUDO) chmod 755 $(DATA_DIRS)

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
	$(SUDO) rm -rf $(DATA_DIRS)

re: fclean all

logs:
	$(COMPOSE) logs -f

# Optional: wipe data using a throwaway container (useful if sudo is unavailable)
.PHONY: wipe-data
wipe-data: down
	# Requires Docker Hub access to pull 'busybox' once
	docker run --rm -v $(MARIADB_DATA_PATH):/data busybox sh -c "find /data -mindepth 1 -maxdepth 1 -exec rm -rf {} + || true"
	docker run --rm -v $(WORDPRESS_DATA_PATH):/data busybox sh -c "find /data -mindepth 1 -maxdepth 1 -exec rm -rf {} + || true"
