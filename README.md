# csgo

The Dockerfile will build an image for running a Counter-Strike: Global Offensive dedicated server.

`start.sh` runs the server when the container starts.

The server matchmaking rules live in `containerfs/csgo/csgo/matchmaking.cfg`.

Run the server in the background:

```
	docker run \
		-d \
		-P \
		-e "SERVER_HOSTNAME=test" \
		-e "SERVER_PASSWORD=test" \
		-e "RCON_PASSWORD=test" \
		-e "STEAM_ACCOUNT=$(STEAM_ACCOUNT)" \
```

Use `docker ps` to see which ports to use, or use `-p` instead of `-P` to override.