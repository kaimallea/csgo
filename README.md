# CSGO containerized

The Dockerfile will build an image for running a Counter-Strike: Global Offensive dedicated server in a container.

The following addons and plugins are included by default:

- [Metamod](https://www.sourcemm.net/)
- [SourceMod](https://www.sourcemod.net/)
- [PugSetup](https://github.com/splewis/csgo-pug-setup)

This means that you can quickly organize a 10mans/gathers/pug by connecting and typing `.setup` in chat.

## How to Use

```bash
docker pull kmallea/csgo:latest
```

To use the image as-is, run it with a few useful environment variables to configure the server:

```bash
docker run \
  --rm \
  --interactive \
  --tty \
  --detach \
  --mount source=csgo-data,target=/home/steam/csgo \
  --network=host \
  --env "SERVER_HOSTNAME=hostname" \
  --env "SERVER_PASSWORD=password" \
  --env "RCON_PASSWORD=rconpassword" \
  --env "STEAM_ACCOUNT=gamelogintoken" \
  --env "SOURCEMOD_ADMINS=STEAM_1:0:123456,STEAM_1:0:654321" \
  kmallea/csgo
```

### Required Game Login Token

The `STEAM_ACCOUNT` is a "Game Login Token" required by Valve to run public servers. Confusingly, this token is also referred to as a steam account (it's set via `sv_setsteamaccount`). To get one, visit https://steamcommunity.com/dev/managegameservers. You'll need one for each server.

### SourceMod admins

The optional `SOURCEMOD_ADMINS` environment variable is a comma-delimited list of Steam IDs. These will be added to SourceMod's admin list before the server is started.

### Playing on LAN

If you're on a LAN, add the environment variable `LAN=1` (e.g., `--env "LAN=1"`) to have `sv_lan 1` set for you in the server.


### Environment variable overrides

Below are the default values for environment variables that control the server configuration. To override, pass one or more of these to docker using the `-e` or `--env` argument (example above).

```bash
SERVER_HOSTNAME=Counter-Strike: Global Offensive Dedicated Server
SERVER_PASSWORD=
RCON_PASSWORD=changeme
STEAM_ACCOUNT=changeme
IP=0.0.0.0
PORT=27015
TV_PORT=27020
TICKRATE=128
FPS_MAX=300
GAME_TYPE=0
GAME_MODE=1
MAP=de_dust2
MAPGROUP=mg_active
MAXPLAYERS=12
TV_ENABLE=1
LAN=0
SOURCEMOD_ADMINS=
```

### Troubleshooting

If you're unable to use [`--network=host`](https://docs.docker.com/network/host/), you'll need to publsh the ports instead, e.g.:

```bash
docker run \
  --rm \
  --interactive \
  --tty \
  --detach \
  --mount source=csgo-data,target=/home/steam/csgo \
  --publish 27015:27015/tcp \
  --publish 27015:27015/udp \
  --publish 27020:27020/tcp \
  --publish 27020:27020/udp \
  --env "SERVER_HOSTNAME=hostname" \
  --env "SERVER_PASSWORD=password" \
  --env "RCON_PASSWORD=rconpassword" \
  --env "STEAM_ACCOUNT=gamelogintoken" \
  --env "SOURCEMOD_ADMINS=STEAM_1:0:123456,STEAM_1:0:654321" \
  kmallea/csgo
```

## Manually Building

```bash
docker build -t csgo-dedicated-server .
```

_OR_

```bash
make
```

The game data is downloaded on first run (~26GB). Mount a data volume (not a bind volume) to preserve game data if you need to recreate the container. The volume target is `/home/steam/csgo`.

### Overriding versions of SteamCMD, Metamod, SourceMod, and/or PugSetup

You can pass build arguments to override the URLs used to fetch SteamCmd, Metamod, SourceMod, PugSetup:

```bash
docker build \
  -t $(IMAGE_NAME) \
  --build-arg STEAMCMD_URL=https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
  --build-arg METAMOD_PLUGIN_URL=https://mms.alliedmods.net/mmsdrop/1.10/mmsource-1.10.7-git971-linux.tar.gz \
  --build-arg SOURCEMOD_PLUGIN_URL=https://sm.alliedmods.net/smdrop/1.10/sourcemod-1.10.0-git6474-linux.tar.gz \
  --build-arg PUGSETUP_PLUGIN_URL=https://github.com/splewis/csgo-pug-setup/releases/download/2.0.5/pugsetup_2.0.5.zip \
  .
```

### Adding your own configs, addons, plugins, etc.

The directory `containerfs` (container filesystem) is the equivalent of the steam user's home directory (`/home/steam`). The `csgo` game data lives in here. This means that any files or plugins you want to add, simply put them in the correct paths under `containerfs`, and they will appear in the Docker image relative to the steam user's home directory.

For example, by default, CSGO is installed to `/home/steam/csgo` within the docker image. I want my `practice.cfg` file to live in the `cfg` directory, so I put that file in `containerfs/csgo/csgo/cfg/` and it will appear in the right place inside the docker image (`/home/steam/csgo/csgo/cfg/practice.cfg`).

### Test Locally

After building:

1. Edit the exported environment variables in the `Makefile` to your liking
2. Run `make test` to start a local LAN server to test