SHELL := /bin/bash
 
IMAGE_NAME ?= csgo-server
STEAM_ACCOUNT ?= changeme-required
CONTAINER_NAME ?= csgo-server
SERVER_HOSTNAME ?= test
SERVER_PASSWORD ?= test
RCON_PASSWORD ?= test
TICKRATE ?= 128
GAME_TYPE ?= 0
GAME_MODE ?= 1
MAP ?= de_dust2
MAPGROUP ?= mg_active
MAXPLAYERS ?= 12

.PHONY: all clean image run stop

all: image

clean:
	docker rmi $(IMAGE_NAME)

image: Dockerfile
	docker build -t $(IMAGE_NAME) .

run:
	docker run \
		-d \
		-p 27015:27015/tcp \
		-p 27015:27015/udp \
		-p 27020:27020/udp \
		-p 27020:27020/tcp \
		-e "SERVER_HOSTNAME=$(SERVER_HOSTNAME)" \
		-e "SERVER_PASSWORD=$(SERVER_PASSWORD)" \
		-e "RCON_PASSWORD=$(RCON_PASSWORD)" \
		-e "STEAM_ACCOUNT=$(STEAM_ACCOUNT)" \
		-e "TICKRATE=$(TICKRATE)" \
		-e "GAME_TYPE=$(GAME_TYPE)" \
		-e "GAME_MODE=$(GAME_MODE)" \
		-e "MAP=$(MAP)" \
		-e "MAPGROUP=$(MAPGROUP)" \
		-e "MAXPLAYERS=$(MAXPLAYERS)" \
		--name $(CONTAINER_NAME)" \
		$(IMAGE_NAME)

stop:
	docker stop $(CONTAINER_NAME)
	docker rm $(CONTAINER_NAME)
