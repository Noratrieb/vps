#!/usr/bin/env bash

set -euxo pipefail

BUCKET=nilstrieb-backups
PREFIX="1/$(date --rfc-3339 seconds --utc)"

cd /apps

function upload_file {
    local file="$1"
    local tmppath
    tmppath="$(mktemp)"

    cp "$file" "$tmppath"
    xz "$tmppath"
    aws s3api put-object --bucket "$BUCKET" --key "${PREFIX}/${file}.xz" --body "${tmppath}.xz"

    rm "$tmppath.xz"
}

function upload_pg_dump {
    local appname="$1"
    local containername="$2"
    local dbname="$3"
    local username="$4"
    local tmppath
    tmppath="$(mktemp)"

    docker exec "$containername" pg_dump --format=custom --file /tmp/db.bak --host "127.0.0.1"  --dbname "$dbname" --username "$username"
    docker cp "$containername:/tmp/db.bak" "$tmppath"
    xz "$tmppath"
    aws s3api put-object --bucket "$BUCKET" --key "${PREFIX}/$appname/postgres.bak.xz" --body "$tmppath.xz"

    docker exec "$containername" rm "/tmp/db.bak"
    rm "$tmppath.xz"
}

function upload_dump_mongo {
    local appname="$1"
    local containername="$2"
    local usernamepassword="$3"
    local tmppath
    tmppath="$(mktemp)"

    docker exec "$containername" mongodump --archive=/tmp/db.bak --uri="mongodb://${usernamepassword}@127.0.0.1:27017"
    docker cp "$containername:/tmp/db.bak" "$tmppath"
    xz "$tmppath"
    aws s3api put-object --bucket "$BUCKET" --key "${PREFIX}/$appname/db.bak.xz" --body "$tmppath.xz"

    docker exec "$containername" rm "/tmp/db.bak"
    rm "$tmppath.xz"
}

function upload_directory {
    local appname="$1"
    local directory="$2"
    local filename="$3"
    local tmppath
    tmppath="$(mktemp)"

    tar -cJf "$tmppath" "$directory"
    aws s3api put-object --bucket "$BUCKET" --key "${PREFIX}/$appname/$filename" --body "$tmppath"

    rm "$tmppath"
}

upload_file "bisect-rustc-service/db.sqlite"
upload_file "killua/trivia_questions.json"
#upload_file "uptime/uptime.db"

upload_pg_dump "cors-school" "cors-school-db" "davinci" "postgres"
#upload_pg_dump "hugo-chat" "hugo-chat-db" "postgres" "postgres"
upload_pg_dump "openolat" "openolat-db" "oodb" "oodbu"

# shellcheck disable=SC1091
source "karin-bot/.env"
upload_dump_mongo "karin-bot" "karin-bot-db" "$MONGO_INITDB_ROOT_USERNAME:$MONGO_INITDB_ROOT_PASSWORD"

upload_directory "openolat" "openolat/olatdata" "olatdata.tar.xz"

echo "Finished backup!"
