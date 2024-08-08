#!/usr/bin/env bash

set -euo pipefail

time="$(date --iso-8601=s --utc)"
echo "Starting backup procedure with time=$time"

dir=$(mktemp -d)
echo "Setting workdir to $dir"
cd "$dir"
export HOME="$dir"
# Delete the temporary directory afterwards.
# Yes, this variable should expand now.
# shellcheck disable=SC2064
trap "rm -rf $dir" EXIT

echo "Logging into garage"
export MC_CONFIG_DIR="$dir"
mc alias set garage "$S3_ENDPOINT" "$S3_ACCESS_KEY" "$S3_SECRET_KEY" --api S3v4

mc ls garage/backups

files=$(jq -c '.files[]' "$CONFIG_FILE")
pg_dumps=$(jq -c '.pg_dumps[]' "$CONFIG_FILE")

echo "$files"
echo "$pg_dumps"

IFS=$'\n'
for file_config in $files; do
    filepath=$(echo "$file_config" | jq -r ".file")
    app=$(echo "$file_config" | jq -r ".app")

    echo "Backing up app $app FILE $filepath..."
    tmppath="$dir/file"
    xz < "$filepath" > "$tmppath"

    echo "Uplading file"
    mc put "$tmppath" "garage/$S3_BUCKET/$app/$time/$(basename "$filepath").xz"
    echo "Uploaded file"
done

for pg_config in $pg_dumps; do
    app=$(echo "$pg_config" | jq -r ".app")
    containerName=$(echo "$pg_config" | jq -r ".containerName")
    dbName=$(echo "$pg_config" | jq -r ".dbName")
    userName=$(echo "$pg_config" | jq -r ".userName")

    echo "Backing up app $app POSTGRES $containerName/$dbName..."
    tmppath="$dir/file"
    
    podman exec "$containerName" pg_dump --format=custom --file /tmp/db.bak \
        --host "127.0.0.1"  --dbname "$dbName" --username "$userName"
    podman cp "$containerName:/tmp/db.bak" "$tmppath"
    xz -f "$tmppath" > "$tmppath.xz"

    echo "Uplading file"
    mc put "$tmppath.xz" "garage/$S3_BUCKET/$app/$time/$dbName.bak.xz"
    echo "Uploaded file"

    podman exec "$containerName" rm "/tmp/db.bak"
done
