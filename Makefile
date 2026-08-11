NAME = inception
COMPOSE = docker compose -f srcs/docker-compose.yml

all: up

up:
	@mkdir -p /home/$(USER)/data/mariadb /home/$(USER)/data/wordpress /home/$(USER)/data/redis /home/$(USER)/data/portainer
	$(COMPOSE) up --build -d

down:
	$(COMPOSE) down

stop:
	$(COMPOSE) stop

start:
	$(COMPOSE) start

restart: down up

clean: down
	docker system prune -af

fclean: clean
	$(COMPOSE) down -v
	sudo rm -rf /home/$(USER)/data/mariadb/*
	sudo rm -rf /home/$(USER)/data/wordpress/*
	sudo rm -rf /home/$(USER)/data/redis/*
	sudo rm -rf /home/$(USER)/data/portainer/*

re: fclean up

.PHONY: all up down stop start restart clean fclean re