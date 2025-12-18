COMPOSE_FILE := srcs/docker-compose.yml
COMPOSE      := docker compose -f $(COMPOSE_FILE)

# Host data paths (override via environment if needed)
MARIADB_DATA_PATH    ?= /home/mzhivoto/data/mariadb
WORDPRESS_DATA_PATH  ?= /home/mzhivoto/data/wordpress
DATA_DIRS            := $(MARIADB_DATA_PATH) $(WORDPRESS_DATA_PATH)

.PHONY: all up build down clean fclean re logs prepare-dirs

all: up

prepare-dirs:
	mkdir -p $(DATA_DIRS)

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

re: fclean all

logs:
	$(COMPOSE) logs -f
