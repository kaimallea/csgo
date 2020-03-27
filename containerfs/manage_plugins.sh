#!/usr/bin/env bash

set -ueo pipefail

: "${CSGO_DIR:?'ERROR: CSGO_DIR IS NOT SET!'}"

export RETAKES="${RETAKES:-0}"

INSTALL_PLUGINS="${INSTALL_PLUGINS:-https://mms.alliedmods.net/mmsdrop/1.10/mmsource-1.10.7-git971-linux.tar.gz
https://sm.alliedmods.net/smdrop/1.10/sourcemod-1.10.0-git6478-linux.tar.gz
https://github.com/splewis/csgo-pug-setup/releases/download/2.0.5/pugsetup_2.0.5.zip
https://github.com/splewis/csgo-retakes/releases/download/v0.3.4/retakes_0.3.4.zip
https://github.com/b3none/retakes-instadefuse/releases/download/1.4.0/retakes-instadefuse.smx
https://github.com/b3none/retakes-autoplant/releases/download/2.3.0/retakes_autoplant.smx
https://github.com/b3none/retakes-hud/releases/download/2.2.5/retakes-hud.smx
}"

get_checksum_from_string () {
  local md5
  md5=$(echo -n "$1" | md5sum | awk '{print $1}')
  echo "$md5"
}

is_plugin_installed() {
  local url_hash
  url_hash=$(get_checksum_from_string "$1")
  if [[ -f "$CSGO_DIR/csgo/${url_hash}.marker" ]]; then
    return 0
  else
    return 1
  fi
}

create_install_marker() {
  echo "$1" > "$CSGO_DIR/csgo/$(get_checksum_from_string "$1").marker"
}

install_plugin() {
  filename=${1##*/}
  filename_ext=$(echo "${1##*.}" | awk '{print tolower($0)}')
  if ! is_plugin_installed "$1"; then
    echo "Downloading $1..."
    case "$filename_ext" in
      "gz")
        curl -sSL "$1" | tar -zx -C "$CSGO_DIR/csgo"
        echo "Extracting $filename..."
        create_install_marker "$1"
        ;;
      "zip")
        curl -sSL -o "$filename" "$1"
        echo "Extracting $filename..."
        unzip -oq "$filename" -d "$CSGO_DIR/csgo"
        rm "$filename"
        create_install_marker "$1"
        ;;
      "smx")
        (cd "$CSGO_DIR/csgo/addons/sourcemod/plugins/" && curl -sSLO "$1")
        create_install_marker "$1"
        ;;
      *)
        echo "Plugin $filename has an unknown file extension, skipping"
        ;;
    esac
  else
    echo "Plugin $filename is already installed, skipping"
  fi
}

echo "Installing plugins..."

mkdir -p "$CSGO_DIR/csgo"
IFS=' ' read -ra PLUGIN_URLS <<< "$(echo "$INSTALL_PLUGINS" | tr "\n" " ")"
for URL in "${PLUGIN_URLS[@]}"; do
  install_plugin "$URL"
done

echo "Finished installing plugins."

# Add steam ids to sourcemod admin file
mkdir -p "$CSGO_DIR/csgo/addons/sourcemod/configs"
IFS=',' read -ra STEAMIDS <<< "$SOURCEMOD_ADMINS"
for id in "${STEAMIDS[@]}"; do
    echo "\"$id\" \"99:z\"" >> "$CSGO_DIR/csgo/addons/sourcemod/configs/admins_simple.ini"
done

PLUGINS_ENABLED_DIR="$CSGO_DIR/csgo/addons/sourcemod/plugins"
PLUGINS_DISABLED_DIR="$CSGO_DIR/csgo/addons/sourcemod/plugins/disabled"
RETAKES_PLUGINS="retakes.smx retakes-instadefuse.smx retakes_autoplant.smx retakes-hud.smx retakes_standardallocator.smx"
PUGSETUP_PLUGINS="pugsetup.smx pugsetup_teamnames.smx pugsetup_damageprint.smx"

# Disable Retakes by default so that we have a working and predictable state without plugins conflict
if [[ -f "$PLUGINS_ENABLED_DIR"/retakes.smx ]]; then
  mv "$PLUGINS_ENABLED_DIR"/retakes*.smx "$PLUGINS_DISABLED_DIR"/
fi

if [ "$RETAKES" = "1" ]; then
  if [[ -f "$PLUGINS_ENABLED_DIR"/pugsetup.smx ]]; then
    (cd "$PLUGINS_ENABLED_DIR" && mv pugsetup*.smx "$PLUGINS_DISABLED_DIR")
    echo "Disabled PugSetup plugins"
  fi
  # shellcheck disable=SC2086
  (cd "$PLUGINS_DISABLED_DIR" && mv $RETAKES_PLUGINS "$PLUGINS_ENABLED_DIR")
  echo "Enabled Retakes plugins"
else
  if [[ -f "$PLUGINS_DISABLED_DIR"/pugsetup.smx ]]; then
    # shellcheck disable=SC2086
    (cd "$PLUGINS_DISABLED_DIR" && mv $PUGSETUP_PLUGINS "$PLUGINS_ENABLED_DIR")
    echo "Enabled PugSetup plugins"
  fi
fi
