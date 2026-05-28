{ config, pkgs, ... }: {
  age.secrets.immich_secrets.file = ../../secrets/immich_secrets.age;

  services.immich = {
    enable = true;
    mediaLocation = "/mnt/nas/HEY/_Nora/immich";
    secretsFile = config.age.secrets.immich_secrets.path;
    host = "0.0.0.0";
    database = {
      enableVectors = false;
      enableVectorChord = true;
    };
    openFirewall = true;
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
}
