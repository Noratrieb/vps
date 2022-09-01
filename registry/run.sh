#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ "$STAGE" = "localhost" ] ;
then
    echo "INFO Running on localhost"
    CERT_VOLUME=""
else
    echo "INFO Running on prod"
    CERT_VOLUME="\
        -v=/etc/letsencrypt:/etc/letsencrypt \
        -v=/etc/htpasswd:/htpasswd \
        -e=REGISTRY_HTTP_TLS_CERTIFICATE=/etc/letsencrypt/live/nilstrieb.dev/fullchain.pem \
        -e=REGISTRY_HTTP_TLS_KEY=/etc/letsencrypt/live/nilstrieb.dev/privkey.pem \
        -e=REGISTRY_AUTH=htpasswd \
        -e=REGISTRY_AUTH_HTPASSWD_REALM=Realm \
        -e=REGISTRY_AUTH_HTPASSWD_PATH=/htpasswd \
    "
fi

if docker container inspect registry > /dev/null 2>&1 ;
then
    echo "INFO Registry container exists already..."
else
    docker run -d --restart=always --name registry \
        -v "$SCRIPT_DIR/config.yml:/etc/docker/registry/config.yml" \
        -v "/var/lib/docker/registry:/var/lib/registry" \
        $CERT_VOLUME \
        --net internal \
        registry:2
fi