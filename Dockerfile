FROM ubuntu:bionic

ENV LAST_UPDATED_AT 2020-03-01

# Install dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -yq \
  lib32gcc1 \
  lib32stdc++6 \
  ca-certificates \
  locales \
  unzip \
  && rm -rf /var/lib/apt/lists/* \
  && locale-gen "en_US.UTF-8"

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Install SteamCMD
RUN adduser --disabled-password --gecos "" steam
USER steam
ENV STEAMCMD_DIR /home/steam/steamcmd
RUN mkdir ${STEAMCMD_DIR}
WORKDIR ${STEAMCMD_DIR}
ARG steamcmd_url=https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
ADD --chown=steam ${steamcmd_url} steamcmd_linux.tar.gz
RUN tar -zxvf steamcmd_linux.tar.gz && rm steamcmd_linux.tar.gz

# Patch the following error:
# /home/steam/.steam/sdk32/steamclient.so: cannot open shared object file: No such file or directory
RUN	mkdir -p /home/steam/.steam/sdk32 \
  && ln -s /home/steam/steamcmd/linux32/steamclient.so /home/steam/.steam/sdk32/steamclient.so
  
# Install CSGO
ENV CSGO_DIR=/home/steam/csgo
RUN ./steamcmd.sh +login anonymous +force_install_dir ${CSGO_DIR} +app_update 740 validate +quit
WORKDIR ${CSGO_DIR}

# Copy in external files
COPY --chown=steam containerfs /home/steam/csgo/

WORKDIR ${CSGO_DIR}/csgo

# Install Metamod
ARG metamod_url=https://mms.alliedmods.net/mmsdrop/1.10/mmsource-1.10.7-git971-linux.tar.gz
ADD --chown=steam ${metamod_url} metamod.tar.gz
RUN tar -zxf metamod.tar.gz && rm metamod.tar.gz

# Install Sourcemod
ARG sourcemod_url=https://sm.alliedmods.net/smdrop/1.10/sourcemod-1.10.0-git6474-linux.tar.gz
ADD --chown=steam ${sourcemod_url} sourcemod.tar.gz
RUN tar -zxf sourcemod.tar.gz && rm sourcemod.tar.gz

# Install PUG plugin
ARG pug_setup_plugin_url=https://github.com/splewis/csgo-pug-setup/releases/download/2.0.5/pugsetup_2.0.5.zip
ADD --chown=steam ${pug_setup_plugin_url} pug_setup_plugin.zip
RUN unzip pug_setup_plugin.zip && rm pug_setup_plugin.zip

WORKDIR ${CSGO_DIR}

CMD ["./start.sh"]
