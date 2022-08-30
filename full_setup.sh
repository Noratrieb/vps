#!/usr/bin/env bash

./docker/setup_net.sh

./registry/run.sh
./nginx/run.sh