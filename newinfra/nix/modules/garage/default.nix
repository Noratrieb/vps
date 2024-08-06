{ config, pkgs, name, ... }: {
  age.secrets.garage_secrets.file = ../../secrets/garage_secrets.age;

  networking.firewall.interfaces.wg0.allowedTCPPorts = [ 3901 ];

  services.garage = {
    enable = true;
    package = pkgs.garage_1_0_0;
    settings = {
      metadata_dir = "/var/lib/garage/meta";
      data_dir = "/var/lib/garage/data";
      db_engine = "sqlite";
      metadata_auto_snapshot_interval = "6h";

      replication_factor = 3;

      # arbitrary, but a bit higher as disk space matters more than time. she says, cluelessly.
      compression-level = 5;

      rpc_bind_addr = "[::]:3901";
      rpc_public_addr = "${name}.local:3901";

      s3_api = {
        s3_region = "garage";
        api_bind_addr = "[::]:3900";
        root_domain = ".s3.garage.localhost";
      };

      s3_web = {
        bind_addr = "[::]:3902";
        root_domain = ".web.garage.localhost";
        index = "index.html";
      };

      admin = {
        api_bind_addr = "[::]:3903";
      };
    };
    environmentFile = config.age.secrets.garage_secrets.path;
  };
}

