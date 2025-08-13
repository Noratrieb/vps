{ pkgs, lib, networkingConfig, config, ... }:
let metricsPort = 9433; in
{
  age.secrets.knot_dns_rfc2136_key_config = {
    file =
      ../../secrets/knot_dns_rfc2136_key_config.age;
    owner = "knot";
  };

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
    keyFiles = [ config.age.secrets.knot_dns_rfc2136_key_config.path ];
    settingsFile = pkgs.writeTextFile {
      name = "knot.conf";
      text = ''
        server:
            listen: 0.0.0.0@53
            listen: ::@53
        
        key:
          - id: rfc2136-update
            algorithm: hmac-sha256
            secret: QRpeYCJLokRWyzT/tWrxaly5Seb5yTkE6/Ub66edWds=
        
        acl:
          - id: update_acl
            address: 10.0.0.0/24
            key: rfc2136-update
            action: update
            update-type: [TXT]

        zone:
          - domain: noratrieb.dev
            storage: /var/lib/knot/zones/
            file: ${import ./noratrieb.dev.nix { inherit pkgs lib networkingConfig; }}
          - domain: nilstrieb.dev
            storage: /var/lib/knot/zones/
            file: ${import ./nilstrieb.dev.nix { inherit pkgs lib networkingConfig; }}
            acl: update_acl
        log:
          - target: syslog
            any: info
      '';
    };
  };

  networking.firewall.interfaces.wg0.allowedTCPPorts = [ metricsPort ];
  services.prometheus.exporters.knot = {
    enable = true;
    port = metricsPort;
  };
}
