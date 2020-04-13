#!/usr/bin/env bash

set -ueo pipefail

: "${CSGO_DIR:?'ERROR: CSGO_DIR IS NOT SET!'}"

PUGSETUP_CONFIG="$CSGODIR/csgo/cfg/sourcemod/pugsetup.cfg"

if [[ -f "$PUGSETUP_CONFIG" ]]; then
    # Update PugSetup cvars specified as envvars.
    # e.g., `SM_PUGSETUP_SNAKE_CAPTAIN_PICKS=2` will set sm_pugsetup_snake_captain_picks "2" inside of $PUGSETUP_CONFIG
    for var in "${!SM_PUGSETUP_@}"; do
        cvar=$(echo "$var" | tr '[:upper:]' '[:lower:]')
        value=${!var}
        sed -i "s/$cvar \"[^\]*\"/$cvar \"$value\"/g" "$PUGSETUP_CONFIG"
    done
fi
