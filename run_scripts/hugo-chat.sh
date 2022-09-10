docker run --net internal --name hugo-chat-frontend -d --restart=always docker.nilstrieb.dev/hugo-chat-frontend:1.0

docker run --net internal --name hugo-chat-db -d -e POSTGRES_PASSWORD=huGO123.corsBOSS postgres

docker run --net internal --name hugo-chat-backend -d docker.nilstrieb.dev/hugo-chat-backend:1.0