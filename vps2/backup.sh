#!/usr/bin/env bash

set -euxo pipefail

BUCKET=nilstrieb-backups
PREFIX="1/$(date --rfc-3339 seconds --utc)"

cd /apps

function upload {
    local file="$1"
    aws s3api put-object --bucket "$BUCKET" --key "${PREFIX}/${file}" --body "${file}"
}

function pg_dump {
    local appname="$1"
    local containername="$2"
    local dbname="$3"
    local username="$4"
    local tmppath
    tmppath="$(mktemp)"

    docker exec "$containername" pg_dump --format=custom --file /tmp/db.bak --host "127.0.0.1"  --dbname "$dbname" --username "$username"
    docker cp "$containername:/tmp/db.bak" "$tmppath"
    aws s3api put-object --bucket "$BUCKET" --key "${PREFIX}/$appname/db.bak" --body "$tmppath"

    docker exec "$containername" rm "/tmp/db.bak"
    rm "$tmppath"
}

function dump_mongo {
    local appname="$1"
    local containername="$2"
    local usernamepassword="$3"
    local tmppath
    tmppath="$(mktemp)"

    docker exec "$containername" mongodump --archive=/tmp/db.bak --uri="mongodb://${usernamepassword}@127.0.0.1:27017"
    docker cp "$containername:/tmp/db.bak" "$tmppath"
    aws s3api put-object --bucket "$BUCKET" --key "${PREFIX}/$appname/db.bak" --body "$tmppath"

    docker exec "$containername" rm "/tmp/db.bak"
    rm "$tmppath"

}

function upload_directory_xz {
    local appname="$1"
    local directory="$2"
    local filename="$3"
    local tmppath
    tmppath="$(mktemp)"

    tar -cJf "$tmppath" "$directory"
    aws s3api put-object --bucket "$BUCKET" --key "${PREFIX}/$appname/$filename" --body "$tmppath"

    rm "$tmppath"
}

upload "bisect-rustc-service/db.sqlite"
upload "killua/trivia_questions.json"
upload "uptime/uptime.db"

pg_dump "cors-school" "cors-school-db" "davinci" "postgres"
pg_dump "hugo-chat" "hugo-chat-db" "postgres" "postgres"
pg_dump "openolat" "openolat-db" "oodb" "oodbu"

# shellcheck disable=SC1091
source "karin-bot/.env"
dump_mongo "karin-bot" "karin-bot-db" "$MONGO_INITDB_ROOT_USERNAME:$MONGO_INITDB_ROOT_PASSWORD"

upload_directory_xz "openolat" "openolat/olatdata" "olatdata.tar.xz"
