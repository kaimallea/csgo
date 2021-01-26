# CSGO containerized

The Dockerfile will build an image for running a Counter-Strike: Global Offensive dedicated server in a container.

The following addons and plugins are included by default:

- [Metamod](https://www.sourcemm.net/)
- [SourceMod](https://www.sourcemod.net/)
- [SteamWorks](https://forums.alliedmods.net/showthread.php?t=229556)
- [Updater](https://bitbucket.org/GoD_Tony/updater/downloads/updater.smx)
- [PugSetup](https://github.com/splewis/csgo-pug-setup)
- [Practice Mode](https://github.com/splewis/csgo-practice-mode)
- [Retakes](https://github.com/splewis/csgo-retakes) (**disabled by default**)

To get a 10man/gather going, simply connect and type `.setup` in chat. Practice Mode should also be available from the menu.

Retakes is disabled by default. To enable it, set the environment variable `RETAKES=1` and restart the container. Use can later use the cvar `sm_retakes_enabled 0` to turn if off on-demand.

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
  --env "AUTHKEY=webapikey" \
  --env "SOURCEMOD_ADMINS=STEAM_1:0:123456,STEAM_1:0:654321" \
  kmallea/csgo
```

Would you rather use a bind volume so that you can access file contents directly? Use `--mount type=bind,source=$(pwd),target=/home/steam/csgo` instead of the one in the example above.

If you plan on managing plugins manually with a bind volume, you might want pass an empty or reduced `INSTALL_PLUGINS` environment variable to prevent conflicts (see below for default value of `INSTALL_PLUGINS`).

### Required Game Login Token

The `STEAM_ACCOUNT` is a "Game Login Token" required by Valve to run public servers. Confusingly, this token is also referred to as a steam account (it's set via `sv_setsteamaccount`). To get one, visit https://steamcommunity.com/dev/managegameservers. You'll need one for each server.

Remember that if you DO NOT give a valid Game Login Token, your server will be restricted to LAN only

### Optional Steam Web API Key for Workshop Content

To access maps and collections from the Workshop, you need to provide a Steam Web API key. You can provide this via the evironment variable `AUTHKEY` and it will be passed to the command-line as `-authkey <key>`.

If you don't have a key you can generate one at http://steamcommunity.com/dev/apikey.

With a key set, you can also use the environment variables `HOST_WORKSHOP_COLLECTION` and `WORKSHOP_START_MAP` to specify a workshop collection and start the server with a workshop map, respectively.

For more information check out the [Valve developer wiki page](https://developer.valvesoftware.com/wiki/CSGO_Workshop_For_Server_Operators#How_to_host_Workshop_Maps_with_a_CS:GO_Dedicated_Server).

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
AUTHKEY=changeme
IP=0.0.0.0
PORT=27015
TV_PORT=27020
TICKRATE=128
FPS_MAX=400
GAME_TYPE=0
GAME_MODE=1
MAP=de_dust2
MAPGROUP=mg_active
HOST_WORKSHOP_COLLECTION=
WORKSHOP_START_MAP=
MAXPLAYERS=12
TV_ENABLE=1
LAN=0
SOURCEMOD=1
SOURCEMOD_ADMINS=
RETAKES=0
NOMASTER=0
```

### PugSetup ConVars

PugSetup's default configuration can also be controlled via environment variables. Any environment variables prefixed with `SM_PUGSETUP_` will have its corresponding cvar updated inside of `$CSGODIR/csgo/cfg/sourcemod/pugsetup.cfg`.

**NOTE: `pugsetup.cfg` is automatically generated the first time the plugin is loaded. So you may have to restart the container after the first run so that the file exists.**

For example, if I wanted to enable set the cvars `sm_pugsetup_snake_captain_picks` and `sm_pugsetup_message_prefix`, I would set the following environment variables when starting the container:

```bash
  ...
  --env "SM_PUGSETUP_SNAKE_CAPTAIN_PICKS=2" \
  --env "SM_PUGSETUP_MESSAGE_PREFIX=[{YELLOW}Sesame Street{NORMAL}]" \
  ...
```

This would set these values in `$CSGODIR/csgo/cfg/sourcemod/pugsetup.cfg`:

```bash
...
sm_pugsetup_snake_captain_picks "2"
sm_pugsetup_message_prefix "[{YELLOW}Sesame Street{NORMAL}]"
...
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
  --env "AUTHKEY=webapikey" \
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

The game data is downloaded on first run (~26GB). Mount a volume to preserve game data if you need to recreate the container. The volume's target should be `/home/steam/csgo`. In these example I use a data volume, but you can use a bind volume as well since plugins are installed during container startup.

### Overriding versions of SteamCMD, Metamod, SourceMod, and/or PugSetup

#### SteamCMD

SteamCMD is installed directly into the image at build time. To override the URL it installs from, pass in a build arg named `STEAMCMD_URL`:

```bash
docker build \
  -t $(IMAGE_NAME) \
  --build-arg STEAMCMD_URL=https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
  .
```

#### Metamod, SourceMod, PugSetup, Retakes, etc

All plugins and extensions are installed during the startup of the container. This allows plugins can be managed via an environment variable.

The environment variable `INSTALL_PLUGINS` contains a space-delimited list of plugins to install. You can use newlines to delimit, they will be converted to spaces before processing. If you override this, make sure you include metamod and sourcemod or plugins that depend on them won't work.

```bash
INSTALL_PLUGINS="${INSTALL_PLUGINS:-https://mms.alliedmods.net/mmsdrop/1.10/mmsource-1.10.7-git971-linux.tar.gz
https://sm.alliedmods.net/smdrop/1.10/sourcemod-1.10.0-git6478-linux.tar.gz
https://github.com/splewis/csgo-pug-setup/releases/download/2.0.5/pugsetup_2.0.5.zip
https://github.com/splewis/csgo-retakes/releases/download/v0.3.4/retakes_0.3.4.zip
https://github.com/b3none/retakes-instadefuse/releases/download/1.4.0/retakes-instadefuse.smx
https://github.com/b3none/retakes-autoplant/releases/download/2.3.0/retakes_autoplant.smx
https://github.com/b3none/retakes-hud/releases/download/2.2.5/retakes-hud.smx
}"
```

Lastly, a checksum is generated for each plugin's URL and is stored as `$CSGO_DIR/csgo/<checksum>.marker` to prevent re-downloading plugins that have already been installed.

### Adding your own configs, other files etc.

#### Build time

The directory `containerfs` (container filesystem) is the equivalent of the steam user's home directory (`/home/steam`). The `csgo` game data lives in here. This means that any files you want to add, simply put them in the correct paths under `containerfs`, and they will appear in the Docker image relative to the steam user's home directory.

It is recommended to use `INSTALL_PLUGINS` environment variable at run time to install plugins, so that they are decoupled from the image.

#### Run time

See `INSTALL_PLUGINS` above in the section above to learn about installing plugins.

If you're using a data volume, you can use the `docker cp` command to copy files from your host machine into the data volume.

If you're using a bind volume, you can copy files in directly. You may want to clear the `INSTALL_PLUGINS` variable if you want to manage everything manually.

### Test Locally

After building:

1. Edit the exported environment variables in the `Makefile` to your liking
2. Run `make server` to start a local LAN server to test
3. Run `make test` to run tests
