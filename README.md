# Infra setup

## TODOS

There are many todos here. First, grep this codebase for `todo`. In addition to that:

- backups
- data replication across the two servers. i have two servers, let's use that power. maybe rsync or something like that?

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
HUGO_CHAT_DB_PASSWORD=
```

## things that shall not be forgotten

there once was some custom k8s cluster setup in `./k8s-cluster`. it was incomplete and pretty cursed.

also some kubernetes config in `./kube`. why.

gloriously not great docker configs in `./docker`.

`nginx`, `registry` with config for the two.

`run_scripts` with not good scripts for starting containers.
