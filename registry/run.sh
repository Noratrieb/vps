#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if docker container inspect registry > /dev/null 2>&1 ;
then
    echo "Registry container exists already..."
else
    docker run -d -p 5000:5000 --restart=always --name registry \
        -v "$SCRIPT_DIR/config.yml:/etc/docker/registry/config.yml" \
        --net internal \
        registry:2
fi