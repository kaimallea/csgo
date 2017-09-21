SHELL := /bin/bash
 
IMAGE_NAME ?= csgo-server
STEAM_ACCOUNT ?= changeme

.PHONY: all clean image run

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
		-e "SERVER_HOSTNAME=test" \
		-e "SERVER_PASSWORD=test" \
		-e "RCON_PASSWORD=test" \
		-e "STEAM_ACCOUNT=$(STEAM_ACCOUNT)" \
		$(IMAGE_NAME)