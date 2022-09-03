# frontend
docker run --net internal --name cors-school-frontend -d --restart=always docker.nilstrieb.dev/cors-school-frontend:1.0.0

# postgres
docker run --net internal -d --name cors-postgres -e POSTGRES_PASSWORD=hugo58hugo -e POSTGRES_DB=davinci postgres

# backend
docker run --net internal -d --name cors-school-backend -e DATABASE_URL=postgres://postgres:hugo58hugo@cors-postgres/davinci -e RUST_LOG=info -e JWT_SECRET='redacted' docker.nilstrieb.dev/cors-school-backend:1.0