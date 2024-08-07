# garage

## layout

- co-ka -> Contabo Karlsruhe
- co-du -> Contabo Düsseldorf
- he-nu -> Hetzner Nürnberg

| name | disk space | identifier | zone  |
| ---- | ---------- | ---------- | ----- |
| vps3 | 70GB       | cabe      | co-du |
| vps3 | 100GB      | 020bd      | co-ka |
| vps4 | 30GB       | 41e40      | he-nu |
| vps5 | 100GB      | 848d8      | co-du |

## buckets

- `caddy-store`: Store for Caddy webservers
    - key `caddy` RW
- `docker-registry`
    - key `docker-registry` RW
- `loki`
    - key `loki` RW

## keys

- `caddy`: `GK25e33d4ba20d54231e513b80`
- `docker-registry`: `GK48011ee5b5ccbaf4233c0e40`
- `loki`: `GK84ffae2a0728abff0f96667b`
