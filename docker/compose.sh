#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ "$STAGE" = "prod" ] ;
then
    export NGINX_CONF_PATH=../nginx/nginx.conf
    EXTRA_ARGS="-f $SCRIPT_DIR/production.yml"
else
    export NGINX_CONF_PATH=../nginx/nginx.local.conf
fi

export REGISTRY_CONF_DIR=../registry

docker compose -f "$SCRIPT_DIR/docker-compose.yml" $@ up -d