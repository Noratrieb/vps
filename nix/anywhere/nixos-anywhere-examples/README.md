# nixos-anywhere-examples

Checkout the [flake.nix](flake.nix) for examples tested on different hosters.

`nix run github:nix-community/nixos-anywhere -- --flake .#hetzner-cloud --target-host root@vps4.infra.noratrieb.dev --generate-hardware-config nixos-generate-config ./hardware-configuration.nix`
