# new infra

New infra based on more servers and more shit.

All servers have their hostname as their name here and are reachable via `$hostname.infra.noratrieb.dev`.
They will have different firewall configurations depending on their roles.

```

--------    --------
| dns1 |    | dns2 |
--------    --------

--------
| vps1 |
--------

```

## DNS

Two [knot-dns](https://www.knot-dns.cz/) nameservers (`dns1`, `dns2`).
All records are fully static, generated in the NixOS config.

## HTTP(S)

Right now, there's only a single server (`vps1`) serving Caddy.

In the future, there might be a second one in a shared-storage HA setup (with a postgres cluster probably)?
