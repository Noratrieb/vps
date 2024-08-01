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

stuff.

## provisioning

NixOS is provisioned by running [nixos-infect](https://github.com/elitak/nixos-infect) over a default image.

> Contabo sets the hostname to something like vmi######.contaboserver.net, Nixos only allows RFC 1035 compliant hostnames (see here).
> Run `hostname something_without_dots` before running the script.
> If you run the script before changing the hostname - remove the /etc/nixos/configuration.nix so it's regenerated with the new hostname.

```
hostname tmp
curl -LO https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect
bash nixos-infect
```
