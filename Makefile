SHELL := /bin/bash

CONTAINER_NAME ?= csgo-dedicated-server 
IMAGE_NAME ?= kmallea/csgo:latest
SERVER_HOSTNAME ?= Counter-Strike: Global Offensive Dedicated Server
SERVER_PASSWORD ?=
RCON_PASSWORD ?= changeme
STEAM_ACCOUNT ?= changeme
AUTHKEY ?= changeme
IP ?= 0.0.0.0
PORT ?= 27015
TV_PORT ?= 27020
TICKRATE ?= 128
THREADS ?= 1
FPS_MAX ?= 400
GAME_TYPE ?= 0
GAME_MODE ?= 1
MAP ?= de_dust2
MAPGROUP ?= mg_active
HOST_WORKSHOP_COLLECTION ?=
WORKSHOP_START_MAP ?=
MAXPLAYERS ?= 12
TV_ENABLE ?= 1
LAN ?= 1
SOURCEMOD_ADMINS ?= STEAM_1:0:123456,STEAM_1:0:654321
RETAKES ?= 0
NOMASTER ?= 0

.PHONY: all clean image test stop

all: image

clean:
	docker rmi $(IMAGE_NAME)

image: Dockerfile
	docker build -t $(IMAGE_NAME) \
	--build-arg STEAMCMD_URL=https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
	.

server:
	docker run \
		-i \
		-t \
		-d \
		--net=host \
		--mount source=csgo-data,target=/home/steam/csgo \
		-e "SERVER_HOSTNAME=$(SERVER_HOSTNAME)" \
		-e "SERVER_PASSWORD=$(SERVER_PASSWORD)" \
		-e "RCON_PASSWORD=$(RCON_PASSWORD)" \
		-e "STEAM_ACCOUNT=$(STEAM_ACCOUNT)" \
		-e "AUTHKEY=$(AUTHKEY)" \
		-e "TICKRATE=$(TICKRATE)" \
		-e "THREADS=$(THREADS)" \
		-e "FPS_MAX=$(FPS_MAX)" \
		-e "GAME_TYPE=$(GAME_TYPE)" \
		-e "GAME_MODE=$(GAME_MODE)" \
		-e "MAP=$(MAP)" \
		-e "MAPGROUP=$(MAPGROUP)" \
		-e "HOST_WORKSHOP_COLLECTION=$(HOST_WORKSHOP_COLLECTION)" \
		-e "WORKSHOP_START_MAP=$(WORKSHOP_START_MAP)" \
		-e "MAXPLAYERS=$(MAXPLAYERS)" \
		-e "TV_ENABLE=$(TV_ENABLE)" \
		-e "LAN=$(LAN)" \
		-e "SOURCEMOD_ADMINS=$(SOURCEMOD_ADMINS)" \
		-e "RETAKES=$(RETAKES)" \
		--name $(CONTAINER_NAME) \
		$(IMAGE_NAME)

test:
	docker run \
		-i \
		-t \
		--rm \
		--net=host \
		--mount type=bind,source="$(PWD)/test",target=/home/steam/csgo \
		-e "CI=true" \
		-e "SERVER_HOSTNAME=$(SERVER_HOSTNAME)" \
		-e "SERVER_PASSWORD=$(SERVER_PASSWORD)" \
		-e "RCON_PASSWORD=$(RCON_PASSWORD)" \
		-e "STEAM_ACCOUNT=$(STEAM_ACCOUNT)" \
		-e "AUTHKEY=$(AUTHKEY)" \
		-e "TICKRATE=$(TICKRATE)" \
		-e "THREADS=$(THREADS)" \
		-e "FPS_MAX=$(FPS_MAX)" \
		-e "GAME_TYPE=$(GAME_TYPE)" \
		-e "GAME_MODE=$(GAME_MODE)" \
		-e "MAP=$(MAP)" \
		-e "MAPGROUP=$(MAPGROUP)" \
		-e "HOST_WORKSHOP_COLLECTION=$(HOST_WORKSHOP_COLLECTION)" \
		-e "WORKSHOP_START_MAP=$(WORKSHOP_START_MAP)" \
		-e "MAXPLAYERS=$(MAXPLAYERS)" \
		-e "TV_ENABLE=$(TV_ENABLE)" \
		-e "LAN=$(LAN)" \
		-e "SOURCEMOD_ADMINS=$(SOURCEMOD_ADMINS)" \
		-e "RETAKES=$(RETAKES)" \
		-e "SM_PUGSETUP_SNAKE_CAPTAIN_PICKS=2" \
		--name $(CONTAINER_NAME) \
		$(IMAGE_NAME)

stop:
	docker stop $(CONTAINER_NAME)
	docker rm $(CONTAINER_NAME)
	