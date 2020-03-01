## Adding your own files, plugins, etc.

The directory `containerfs` (container filesystem) is the equivalent of the root CSGO directory (`/home/steam/csgo`). Any files or plugins you want to add to the image, simply put them in the correct paths under `containerfs`, and they will appear in the Docker image relative to the CSGO directory.

For example, by default, CSGO is installed in the root path `/home/steam/csgo` within the docker image. If I want my `practice.cfg` file to live in the `cfg` directory, I would put that file in `containerfs/csgo/cfg/` and it will appear in the right place inside the docker image: `home/steam/csgo/csgo/cfg/practice.cfg` (Yes, `csgo` appears twice in the path because the CSGO installation has a sub-directory named `csgo`).
