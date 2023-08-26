#/usr/bin/env bash

set -eu

APP="$1"

echo "Checking out $APP"

git clone "https://github.com/Nilstrieb/$APP.git" ../app
cd ../app

CURRENT_COMMIT=$(git rev-parse HEAD | cut -c1-8)
echo "Latest commit of $APP is $CURRENT_COMMIT"

IMAGE_PREFIX="docker.nilstrieb.dev/$APP"
IMAGE_FULL_NAME="$IMAGE_PREFIX:$CURRENT_COMMIT"

docker build . -t "$IMAGE_FULL_NAME"
docker push "$IMAGE_FULL_NAME"
