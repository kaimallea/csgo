#!/bin/bash

GOOGLE_METADATA=${GOOGLE_METADATA:-0}

if [ $GOOGLE_METADATA -eq 1 ]
then
    METADATA_URL="${METADATA_URL:-http://metadata.google.internal/computeMetadata/v1/project/attributes}"

    get_metadata () {
        if [ -z "$1" ]
        then
            local result=""
        else
            local result=$(curl --progress-bar "$METADATA_URL/$1?alt=text" -H "Metadata-Flavor: Google")
        fi

        echo $result
    }

    export SERVER_HOSTNAME="${SERVER_HOSTNAME:-$(get_metadata SERVER_HOSTNAME)}"
    export SERVER_PASSWORD="${SERVER_PASSWORD:-$(get_metadata SERVER_PASSWORD)}"
    export RCON_PASSWORD="${RCON_PASSWORD:-$(get_metadata RCON_PASSWORD)}"
    export STEAM_ACCOUNT="${STEAM_ACCOUNT:-$(get_metadata STEAM_ACCOUNT)}"
    export CSGO_DIR="${CSGO_DIR:-$(get_metadata CSGO_DIR)}"
    export IP="${IP:-$(get_metadata IP)}"
    export PORT="${PORT:-$(get_metadata PORT)}"
    export TICKRATE="${TICKRATE:-$(get_metadata TICKRATE)}"
    export GAME_TYPE="${GAME_TYPE:-$(get_metadata GAME_TYPE)}"
    export GAME_MODE="${GAME_MODE:-$(get_metadata GAME_MODE)}"
    export MAP="${MAP:-$(get_metadata MAP)}"
    export MAPGROUP="${MAPGROUP:-$(get_metadata MAPGROUP)}"
    export MAXPLAYERS="${MAXPLAYERS:-$(get_metadata MAXPLAYERS)}"
else
    export SERVER_HOSTNAME="${SERVER_HOSTNAME:-An Amazing CSGO Server}"
    export SERVER_PASSWORD="${SERVER_PASSWORD:-changeme}"
    export RCON_PASSWORD="${RCON_PASSWORD:-changeme}"
    export STEAM_ACCOUNT="${STEAM_ACCOUNT:-changeme}"
    export CSGO_DIR="${CSGO_DIR:-/csgo}"
    export IP="${IP:-0.0.0.0}"
    export PORT="${PORT:-27015}"
    export TICKRATE="${TICKRATE:-128}"
    export GAME_TYPE="${GAME_TYPE:-0}"
    export GAME_MODE="${GAME_MODE:-1}"
    export MAP="${MAP:-de_dust2}"
    export MAPGROUP="${MAPGROUP:-mg_active}"
    export MAXPLAYERS="${MAXPLAYERS:-12}"
fi

: ${CSGO_DIR:?"ERROR: CSGO_DIR IS NOT SET!"}

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
    -tickrate $TICKRATE \
    -port $PORT \
    -maxplayers_override $MAXPLAYERS \
    +game_type $GAME_TYPE \
    +game_mode $GAME_MODE \
    +mapgroup $MAPGROUP \
    +map $MAP \
    +ip $IP \
    +sv_setsteamaccount $STEAM_ACCOUNT