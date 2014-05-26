FROM kmallea/steamcmd

MAINTAINER Kai Mallea <kmallea@gmail.com>

# Run commands as the steam user
USER steam

# Install CS:GO
RUN mkdir /home/steam/csgo &&\
    cd /home/steam/steamcmd &&\
    ./steamcmd.sh \
        +login anonymous \
        +force_install_dir ../csgo \
        +app_update 740 validate \
        +quit

# Make server port available to host
EXPOSE 27015

# This container will be executable
WORKDIR /home/steam/csgo
ENTRYPOINT ["./srcds_run"]