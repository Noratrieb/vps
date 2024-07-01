#!/usr/bin/env bash

# Copies a base64 encoded deploy key to the servers.

set -eu

printf "Enter private key (base64 encoded): "
read -r key64

private=$(echo "$key64" | base64 -d)
public=$(ssh-keygen -f <(echo "$private") -y)

tmp=$(mktemp -d)
echo "$private" > "$tmp/id"
echo "$public" > "$tmp/id.pub"

delete() {
    rm -r "$tmp"
}
trap delete EXIT

ssh-copy-id -i "$tmp/id" root@vps1.nilstrieb.dev
ssh-copy-id -i "$tmp/id" root@vps2.nilstrieb.dev
