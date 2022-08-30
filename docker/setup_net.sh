NET_NAME="internal"

if docker network inspect "$NET_NAME" > /dev/null 2>&1 ;
then
    echo "Network $NET_NAME exists already...";
else
    echo "Creating network $NET_NAME..."
    docker network create "$NET_NAME"
fi
