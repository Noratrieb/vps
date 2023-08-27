#!/usr/bin/env bash

set -euo pipefail

APP="$1"

if [ "$APP" = "hugo-chat" ]; then
    REPO="https://github.com/C0RR1T/HugoChat.git"
elif [ "$APP" = "cors" ]; then
    REPO="https://github.com/nilstrieb-lehre/davinci-cors.git"
else
    REPO="https://github.com/Nilstrieb/$APP.git"
fi

echo "Checking out $REPO"
git clone "$REPO" ../app
cd ../app

CURRENT_COMMIT=$(git rev-parse HEAD | cut -c1-8)
echo "Latest commit of $APP is $CURRENT_COMMIT"

if [ "$APP" = "hugo-chat" ]; then
    IMAGE_PREFIX="docker.nilstrieb.dev/hugo-chat"
    SERVER_FULL_NAME="$IMAGE_PREFIX-server:$CURRENT_COMMIT"
    CLIENT_FULL_NAME="$IMAGE_PREFIX-client:$CURRENT_COMMIT"

    pushd ./HugoServer
    echo "Building server"
    docker build . -t "$SERVER_FULL_NAME"
    docker push "$SERVER_FULL_NAME"
    popd

    pushd ./hugo-client
    echo "Building client"
    docker build . -t "$CLIENT_FULL_NAME"
    docker push "$CLIENT_FULL_NAME"
    popd

    exit 0
fi

if [ "$APP" = "cors" ]; then
    IMAGE_PREFIX="docker.nilstrieb.dev/cors-school"
    SERVER_FULL_NAME="$IMAGE_PREFIX-server:$CURRENT_COMMIT"
    CLIENT_FULL_NAME="$IMAGE_PREFIX-client:$CURRENT_COMMIT"
    BOT_FULL_NAME="$IMAGE_PREFIX-bot:$CURRENT_COMMIT"

    pushd ./react-frontend
    echo "Building frontend"
    docker build -t "$CLIENT_FULL_NAME" .
    docker push "$SERVER_FULL_NAME"
    popd

    pushd ./rust
    echo "Building bot"
    docker build -t "$SERVER_FULL_NAME" -f Dockerfile.server .
    docker push "$SERVER_FULL_NAME"
    docker build -t "$BOT_FULL_NAME" -f Dockerfile.bot .
    docker push "$BOT_FULL_NAME"
    popd

    exit 0
fi

IMAGE_PREFIX="docker.nilstrieb.dev/$APP"
IMAGE_FULL_NAME="$IMAGE_PREFIX:$CURRENT_COMMIT"

docker build . -t "$IMAGE_FULL_NAME"
docker push "$IMAGE_FULL_NAME"
