{ pkgs, lib, networkingConfig, config, name, ... }:
let metricsPort = 9433; in
{
  age.secrets.knot_dns_acme_dns_01_key_config = {
    file =
      ../../secrets/knot_dns_acme_dns_01_key_config.age;
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
    keyFiles = [ config.age.secrets.knot_dns_acme_dns_01_key_config.path ];
    settings = {
      server.listen = [ "0.0.0.0@53" "::@53" ];
      acl = [
        {
          id = "update_acl";
          address = "10.0.0.0/16";
          key = "acme-dns-01";
          action = "update";
          update-type = [ "TXT" ];
        }
      ];
      zone = [
        {
          domain = "noratrieb.dev";
          file = import ./noratrieb.dev.nix { inherit pkgs lib networkingConfig; };
        }

      ] ++ (if name == "dns1" then [
        {
          domain = "nilstrieb.dev";
          file = import ./nilstrieb.dev.nix { inherit pkgs lib networkingConfig; };
        }
        {
          domain = "noratrieb-acme-delegate.dev";
          storage = "/var/lib/knot/zones/";
          file = "noratrieb-acme-delegate.dev.zone";
          acl = "update_acl";
        }
      ] else [ ]);
      log = [{
        target = "syslog";
        any = "info";
      }];
    };
  };

  systemd.services.knot.preStart =
    lib.mkIf (name == "dns1")
      (lib.getExe
        (pkgs.writeShellApplication {
          name = "knot-prestart.sh";
          text = ''
            mkdir -p /var/lib/knot/zones/
            cp ${
              import ./noratrieb-acme-delegate.dev.nix { inherit pkgs lib networkingConfig; }
            } /var/lib/knot/zones/noratrieb-acme-delegate.dev.zone
          '';
        }));

  networking.firewall.interfaces.wg0.allowedTCPPorts = [ metricsPort 53 ];
  services.prometheus.exporters.knot = {
    enable = true;
    port = metricsPort;
  };
}
