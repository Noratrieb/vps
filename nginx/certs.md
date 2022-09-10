```sh
sudo certbot certonly --standalone
```
```
nilstrieb.dev docker.nilstrieb.dev cors-school.nilstrieb.dev api.cors-school.nilstrieb.dev hugo-chat.nilstrieb.dev api.hugo-chat.nilstrieb.dev
```
```sh
sudo tee /etc/letsencrypt/renewal-hooks/pre/001-stop-nginx.sh > /dev/null <<EOF
#!/usr/bin/env bash
docker stop nginx
EOF

sudo tee /etc/letsencrypt/renewal-hooks/post/001-start-nginx.sh > /dev/null <<EOF
#!/usr/bin/env bash
docker start nginx
EOF

sudo chmod +x /etc/letsencrypt/renewal-hooks/pre/001-stop-nginx.sh
sudo chmod +x /etc/letsencrypt/renewal-hooks/post/001-start-nginx.sh
```
