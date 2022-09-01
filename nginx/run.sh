#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if docker container inspect nginx > /dev/null 2>&1 ;
then
    echo "nginx container exists already..."
else
    docker run -d -p 80:80 --restart=always --name nginx \
        -v "$SCRIPT_DIR/nginx.conf:/etc/nginx/nginx.conf:ro" \
        --net internal \
        nginx:latest
fi