#!/usr/bin/env bash

set -euxo pipefail

cd "$(dirname "$(realpath "$0")")/.."

./deploy/smoke-tests.sh

colmena apply --on dns1
./deploy/smoke-tests.sh

colmena apply --on dns2
./deploy/smoke-tests.sh
