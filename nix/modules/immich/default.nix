{ config, pkgs, ... }: {
  age.secrets.immich_secrets.file = ../../secrets/immich_secrets.age;

  services.immich = {
    enable = true;
    mediaLocation = "/mnt/nas/HEY/_Nora/immich";
    secretsFile = config.age.secrets.immich_secrets.path;
    host = "0.0.0.0";
    environment = {
      IMMICH_TELEMETRY_INCLUDE = "all";
    };
  };

  services.postgresql = {
    ensureDatabases = [ "immich" ];
    ensureUsers = [
      {
        name = "immich";
        ensureDBOwnership = true;
      }
    ];
    authentication = pkgs.lib.mkForce ''
      #type database  DBuser  auth-method
      local all       all     peer
    '';
  };

  services.caddy.virtualHosts."immich.internal.noratrieb.dev" = {
    extraConfig = ''
      tls {
        dns_challenge_override_domain "_acme-challenge.immich.internal.noratrieb-acme-delegate.dev"
      }
      reverse_proxy * localhost:${builtins.toString config.services.immich.port}
    '';
  };

  networking.firewall.interfaces.wg0.allowedTCPPorts = [ 8081 8082 ];
}
