{ config, pkgs, name, ... }:
let
  rpcPort = 3901;
  adminPort = 3903;
in
{
  age.secrets.garage_secrets.file = ../../secrets/garage_secrets.age;

  environment.systemPackages = with pkgs; [
    minio-client
  ];

  networking.firewall.interfaces.wg0.allowedTCPPorts = [
    rpcPort
    adminPort
  ];

  systemd.services.garage.serviceConfig = {
    Restart = "on-failure";
  };
  services.garage = {
    enable = true;
    package = pkgs.garage_2_0_0;
    settings = {
      metadata_dir = "/var/lib/garage/meta";
      data_dir = "/var/lib/garage/data";
      db_engine = "sqlite";
      metadata_auto_snapshot_interval = "6h";

      replication_factor = 3;

      # arbitrary, but a bit higher as disk space matters more than time. she says, cluelessly.
      compression-level = 5;

      rpc_bind_addr = "[::]:${toString rpcPort}";
      rpc_public_addr = "${name}.local:${toString rpcPort}";

      s3_api = {
        s3_region = "garage";
        api_bind_addr = "[::]:3900";
        root_domain = ".s3.garage.internal";
      };

      s3_web = {
        bind_addr = "[::]:3902";
        root_domain = ".web.garage.internal";
        index = "index.html";
      };

      admin = {
        api_bind_addr = "[::]:${toString adminPort}";
      };
    };
    environmentFile = config.age.secrets.garage_secrets.path;
  };
}

