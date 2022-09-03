#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ "$STAGE" = "localhost" ] ;
then
    echo "INFO Running on localhost"
    NGINX_CONF="nginx.local.conf"
    EXTRA_ARGS="-p 80:80"
else
    echo "INFO Running on prod"
    NGINX_CONF="nginx.conf"
    EXTRA_ARGS="-v=/etc/letsencrypt:/etc/nginx/certs -p 443:443"
fi

if docker container inspect nginx > /dev/null 2>&1 ;
then
    echo "INFO nginx container exists already..."
else
    docker run -d --restart=always --name=nginx \
        -v="$SCRIPT_DIR/$NGINX_CONF:/etc/nginx/nginx.conf:ro" \
        $EXTRA_ARGS \
        --net=internal \
        nginx:latest
fi