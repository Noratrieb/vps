{ pkgs, lib, networkingConfig, ... }: {
  # get the package for the debugging tools
  environment.systemPackages = with pkgs; [ knot-dns ];

  networking.firewall.allowedUDPPorts = [
    53
  ];

  nixpkgs.overlays = [
    (final: prev: {
      nix-dns = import (pkgs.fetchFromGitHub {
        owner = "nix-community";
        repo = "dns.nix";
        rev = "v1.1.2";
        hash = "sha256-EHiDP2jEa7Ai5ZwIf5uld9RVFcV77+2SUxjQXwJsJa0=";
      });
    })
  ];

  services.knot = {
    enable = true;
    settingsFile = pkgs.writeTextFile {
      name = "knot.conf";
      text = ''
        server:
            listen: 0.0.0.0@53
            listen: ::@53

        zone:
          - domain: noratrieb.dev
            storage: /var/lib/knot/zones/
            file: ${import ./noratrieb.dev.nix { inherit pkgs lib networkingConfig; }}
          - domain: nilstrieb.dev
            storage: /var/lib/knot/zones/
            file: ${import ./nilstrieb.dev.nix { inherit pkgs lib networkingConfig; }}
        log:
          - target: syslog
            any: info
      '';
    };
  };
}
