#!/usr/bin/env bash

set -euxo pipefail

dir=$(realpath "$(dirname "$0")")
cd "$dir"

for secret in ../../secrets-git-crypt/*; do
    agename="$(basename "$secret" | sed 's/\./_/').age"
    rm -f "$agename"
    agenix -e "$agename" < "$secret"
done
