SHELL := /bin/bash

CONTAINER_NAME ?= csgo-dedicated-server 
IMAGE_NAME ?= kmallea/csgo:latest
SERVER_HOSTNAME ?= Counter-Strike: Global Offensive Dedicated Server
SERVER_PASSWORD ?= changeme
RCON_PASSWORD ?= changeme
STEAM_ACCOUNT ?= changeme
IP ?= 0.0.0.0
PORT ?= 27015
TV_PORT ?= 27020
TICKRATE ?= 128
GAME_TYPE ?= 0
GAME_MODE ?= 1
MAP ?= de_dust2
MAPGROUP ?= mg_active
MAXPLAYERS ?= 12
TV_ENABLE ?= 1
LAN ?= 1
SOURCEMOD_ADMINS ?= changeme

.PHONY: all clean image test stop

all: image

clean:
	docker rmi $(IMAGE_NAME)

image: Dockerfile
	docker build \
		-t $(IMAGE_NAME) \
		--build-arg STEAMCMD_URL=https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
		--build-arg METAMOD_PLUGIN_URL=https://mms.alliedmods.net/mmsdrop/1.10/mmsource-1.10.7-git971-linux.tar.gz \
		--build-arg SOURCEMOD_PLUGIN_URL=https://sm.alliedmods.net/smdrop/1.10/sourcemod-1.10.0-git6474-linux.tar.gz \
		--build-arg PUGSETUP_PLUGIN_URL=https://github.com/splewis/csgo-pug-setup/releases/download/2.0.5/pugsetup_2.0.5.zip \
		.

test:
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
		-e "TICKRATE=$(TICKRATE)" \
		-e "GAME_TYPE=$(GAME_TYPE)" \
		-e "GAME_MODE=$(GAME_MODE)" \
		-e "MAP=$(MAP)" \
		-e "MAPGROUP=$(MAPGROUP)" \
		-e "MAXPLAYERS=$(MAXPLAYERS)" \
		-e "TV_ENABLE=$(TV_ENABLE)" \
		-e "LAN=$(LAN)" \
		-e "SOURCEMOD_ADMINS=$(SOURCEMOD_ADMINS)" \
		--name $(CONTAINER_NAME) \
		$(IMAGE_NAME)

stop:
	docker stop $(CONTAINER_NAME)
	docker rm $(CONTAINER_NAME)
	