#!/bin/bash

export METADATA_URL="${METADATA_URL:-http://metadata.google.internal/computeMetadata/v1/project/attributes}"

export SERVER_HOSTNAME="${SERVER_HOSTNAME:-$(curl '$METADATA_URL/SERVER_HOSTNAME?alt=text' -H 'Metadata-Flavor: Google')}"
export SERVER_PASSWORD="${SERVER_PASSWORD:-$(curl '$METADATA_URL/SERVER_PASSWORD?alt=text' -H 'Metadata-Flavor: Google')}"
export RCON_PASSWORD="${RCON_PASSWORD:-$(curl '$METADATA_URL/RCON_PASSWORD?alt=text' -H 'Metadata-Flavor: Google')}"
export STEAM_ACCOUNT="${STEAM_ACCOUNT:-$(curl '$METADATA_URL/STEAM_ACCOUNT?alt=text' -H 'Metadata-Flavor: Google')}"

export CSGO_DIR="${CSGO_DIR:-/csgo}"

cd $CSGO_DIR

### Create dynamic server config
cat << SERVERCFG > $CSGO_DIR/csgo/cfg/server.cfg
hostname "$SERVER_HOSTNAME"
rcon_password "$RCON_PASSWORD"
sv_password "$SERVER_PASSWORD"
sv_lan 0
sv_cheats 0
SERVERCFG

./srcds_run \
    -console \
    -usercon \
    -game csgo \
    -tickrate 128 \
    -maxplayers_override 24 \
    +game_type 0 \
    +game_mode 1 \
    +mapgroup mg_active \
    +map de_dust2 \
    +ip 0.0.0.0 \
    +exec matchmaking.cfg \
    +sv_setsteamaccount $STEAM_ACCOUNT