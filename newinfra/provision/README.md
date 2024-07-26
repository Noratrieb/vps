# provisioning

NixOS is provisioned by running [nixos-infect](https://github.com/elitak/nixos-infect) over a default image.

> Contabo sets the hostname to something like vmi######.contaboserver.net, Nixos only allows RFC 1035 compliant hostnames (see here).
> Run `hostname something_without_dots` before running the script.
> If you run the script before changing the hostname - remove the /etc/nixos/configuration.nix so it's regenerated with the new hostname.

```
curl -LO https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect
bash nixos-infect
```
