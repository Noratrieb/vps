#/usr/bin/env bash

set -eu

APP="$1"

if [ "$APP" = "hugo-chat" ]; then
    git clone "https://github.com/C0RR1T/HugoChat.git" ../app
    cd ../app

    CURRENT_COMMIT=$(git rev-parse HEAD | cut -c1-8)
    echo "Latest commit of $APP is $CURRENT_COMMIT"

    IMAGE_PREFIX="docker.nilstrieb.dev/hugo-chat"
    SERVER_FULL_NAME="$IMAGE_PREFIX-server:$CURRENT_COMMIT"
    CLIENT_FULL_NAME="$IMAGE_PREFIX-client:$CURRENT_COMMIT"

    cd ./HugoServer
    echo "Building server"
    docker build . -t "$SERVER_FULL_NAME"
    docker push "$SERVER_FULL_NAME"

    cd ../hugo-client
    echo "Building client"
    docker build . -t "$CLIENT_FULL_NAME"
    docker push "$CLIENT_FULL_NAME"
fi

echo "Checking out $APP"

git clone "https://github.com/Nilstrieb/$APP.git" ../app
cd ../app

CURRENT_COMMIT=$(git rev-parse HEAD | cut -c1-8)
echo "Latest commit of $APP is $CURRENT_COMMIT"

IMAGE_PREFIX="docker.nilstrieb.dev/$APP"
IMAGE_FULL_NAME="$IMAGE_PREFIX:$CURRENT_COMMIT"

docker build . -t "$IMAGE_FULL_NAME"
docker push "$IMAGE_FULL_NAME"
