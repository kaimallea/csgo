FROM ubuntu:bionic

ENV TERM xterm

ENV STEAM_DIR /home/steam
ENV STEAMCMD_DIR /home/steam/steamcmd
ENV CSGO_APP_ID 740
ENV CSGO_DIR /home/steam/csgo

SHELL ["/bin/bash", "-c"]

ARG STEAMCMD_URL=https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz

RUN set -xo pipefail \
      && apt-get update \
      && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends --no-install-suggests -y \
          lib32gcc1 \
          lib32stdc++6 \
          ca-certificates \
          net-tools \
          locales \
          curl \
          unzip \
      && locale-gen en_US.UTF-8 \
      && adduser --disabled-password --gecos "" steam \
      && mkdir ${STEAMCMD_DIR} \
      && cd ${STEAMCMD_DIR} \
      && curl -sSL ${STEAMCMD_URL} | tar -zx -C ${STEAMCMD_DIR} \
      && mkdir -p ${STEAM_DIR}/.steam/sdk32 \
      && ln -s ${STEAMCMD_DIR}/linux32/steamclient.so ${STEAM_DIR}/.steam/sdk32/steamclient.so \
      && { \
            echo '@ShutdownOnFailedCommand 1'; \
            echo '@NoPromptForPassword 1'; \
            echo 'login anonymous'; \
            echo 'force_install_dir ${CSGO_DIR}'; \
            echo 'app_update ${CSGO_APP_ID}'; \
            echo 'quit'; \
        } > ${STEAM_DIR}/autoupdate_script.txt \
      && mkdir ${CSGO_DIR} \
      && chown -R steam:steam ${STEAM_DIR} \
      && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

COPY --chown=steam:steam containerfs ${STEAM_DIR}/

USER steam
WORKDIR ${CSGO_DIR}
VOLUME ${CSGO_DIR}
ENTRYPOINT exec ${STEAM_DIR}/start.sh
