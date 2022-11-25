#!/usr/bin/env bash

set -eu pipefail

docker run -d --name cargo-bisect-rustc-service --net=internal --restart=always  \
                                "-v=/apps/cargo-bisect-rustc-service/db:/app/db" \
                                "-e=SQLITE_DB=/app/db/db.sqlite" "-e=RUST_LOG=debug" \
                                 docker.nilstrieb.dev/cargo-bisect-rustc-service:1.8
