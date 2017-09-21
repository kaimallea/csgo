# CSGO

The Dockerfile will build an image for running a Counter-Strike: Global Offensive dedicated server in a container.

### Build image

```bash
docker build -t csgo-server .
```

_OR_

```bash
make
```

The game is ~16GB, so the initial build will take a bit to download, depending on your download speed. Subsequent builds on the same machine should take only a few seconds, assuming the initial build image is cached by docker.

### Run a CSGO dedicated server

```bash
docker run \
	-d \
	-p 27015:27015/tcp \
	-p 27015:27015/udp \
	-p 27020:27020/udp \
	-p 27020:27020/tcp \
	-e "SERVER_HOSTNAME=hostname" \
	-e "SERVER_PASSWORD=password" \
	-e "RCON_PASSWORD=rconpassword" \
	-e "STEAM_ACCOUNT=gamelogintoken" \
	csgo-server
```

_OR_

```bash
make run
```

Valve requires a "Game Login Token" to run public servers. Confusingly, this token is also referred to as a steam account (it gets set on the server using `sv_setsteamaccount`). To get one, visit http://steamcommunity.com/dev/managegameservers. You'll need one for each server.

## Environment variable overrides

Below are the default values for environment variables that control the server configuration. Pass one or more of these to docker using the `-e` argument (example above) to override.

```bash
SERVER_HOSTNAME=An Amazing CSGO Server
SERVER_PASSWORD=changeme
RCON_PASSWORD=changeme
STEAM_ACCOUNT=changeme
CSGO_DIR=/csgo
IP=0.0.0.0
PORT=27015
TICKRATE=128
GAME_TYPE=0
GAME_MODE=1
MAP=de_dust2
MAPGROUP=mg_active
MAXPLAYERS=12
```

See `containerfs/csgo/start.sh` to understand more. The command-line arguments are at the bottom of the file.

## Adding files, plugins, etc.

The directory `containerfs` (container filesystem) is the equivalent of the root path (`/`). Any files or plugins you want to add, simply put them in the correct paths under `containerfs`, and they will appear in the same location in the container (except `containerfs` will be replaced with `/`).

For example, by default, CSGO is installed in the root path `/csgo` within the docker image. I want my `matchmaking.cfg` file to live in the `cfg` directory, so I put that file in `containerfs/csgo/cfg/` and it appears in the right place inside the docker image (`/csgo/cfg/matchmaking.cfg`).

## Google Compute Engine Metadata

Passing `GOOGLE_METADATA=1` fetches default values for environment variables from Google Compute Engine's Project or Instance Metadata. Right now it defaults to project level, but you can simply override METADATA_URL to point to instance data.

See https://cloud.google.com/compute/docs/storing-retrieving-metadata#querying.