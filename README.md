# csgo

The Dockerfile will build an image for running a Counter-Strike: Global Offensive dedicated server.

It behaves like an executable, so just pass it args. An example to start a classic casual server:

```
docker run -it kmallea/csgo -game csgo -console -usercon +game_type 0 +game_mode 0 +mapgroup mg_bomb +map de_dust2
```
