#!/usr/bin/env bash

docker run -d -p 8080:80 --restart=always --name nginx \
             -v `pwd`/nginx.conf:/etc/nginx/nginx.conf:ro \
             $@ \
             nginx:latest