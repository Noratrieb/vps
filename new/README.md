# exciting new stuff!!

## server??

Each VPS has a caddy running _on the host_, not inside docker. It's the entrypoint to the stuff.
Everything else runs in a docker container via docker compose.

## extra setup

every app needs some secrets in places.

there are also "global secrets" used for the docker-compose, for example
for env vars. those should be placed in `/apps/.env`.

Right now the global secrets are

```
KILLUA_BOT_TOKEN=
```
