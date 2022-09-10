#!/usr/bin/env bash
set -eu pipefail

./docker/setup_net.sh

./registry/run.sh
./nginx/run.sh