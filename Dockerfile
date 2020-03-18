FROM ubuntu:bionic

ENV TERM xterm

ENV STEAM_DIR /home/steam
ENV STEAMCMD_DIR /home/steam/steamcmd
ENV CSGO_APP_ID 740
ENV CSGO_DIR /home/steam/csgo

SHELL ["/bin/bash", "-c"]

ARG ENTRYPOINT_SCRIPT_URL=https://raw.githubusercontent.com/kaimallea/csgo/master/containerfs/start.sh
ARG STEAMCMD_URL=https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
ARG METAMOD_PLUGIN_URL=https://mms.alliedmods.net/mmsdrop/1.10/mmsource-1.10.7-git971-linux.tar.gz
ARG SOURCEMOD_PLUGIN_URL=https://sm.alliedmods.net/smdrop/1.10/sourcemod-1.10.0-git6474-linux.tar.gz
ARG PUGSETUP_PLUGIN_URL=https://github.com/splewis/csgo-pug-setup/releases/download/2.0.5/pugsetup_2.0.5.zip

RUN set -xo pipefail \
      && apt-get update \
      && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends --no-install-suggests -y \
          lib32gcc1 \
          lib32stdc++6 \
          ca-certificates \
          net-tools \
          locales \
          unzip \
          curl \
      && locale-gen en_US.UTF-8 \
      && adduser --disabled-password --gecos "" steam \
      && mkdir ${STEAMCMD_DIR} \
      && cd ${STEAMCMD_DIR} \
      && curl -sSL ${STEAMCMD_URL} | tar -zx -C ${STEAMCMD_DIR} \
      && mkdir -p ${STEAM_DIR}/.steam/sdk32 \
      && ln -s ${STEAMCMD_DIR}/linux32/steamclient.so ${STEAM_DIR}/.steam/sdk32/steamclient.so \
      && mkdir -p ${CSGO_DIR}/csgo \
      && cd ${CSGO_DIR}/csgo \
      && curl -sSL ${METAMOD_PLUGIN_URL} | tar -zx -C ${CSGO_DIR}/csgo \
      && curl -sSL ${SOURCEMOD_PLUGIN_URL} | tar -zx -C ${CSGO_DIR}/csgo \
      && curl -sSL -o pugsetup.zip ${PUGSETUP_PLUGIN_URL} \
      && unzip -q pugsetup.zip -d ${CSGO_DIR}/csgo \
      && rm pugsetup.zip \
      && chown -R steam:steam ${STEAM_DIR} \
      && apt-get remove -y curl unzip \
      && apt-get autoremove -y \
      && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

COPY --chown=steam:steam containerfs ${CSGO_DIR}/

WORKDIR ${CSGO_DIR}
USER steam
VOLUME ${CSGO_DIR}

ENTRYPOINT ["./start.sh"]
