{ config, lib, pkgs, ... }:
let
  jarfile = pkgs.fetchurl {
    url =
      "https://github.com/C0RR1T/HugoChat/releases/download/2024-08-05/HugoServer.jar";
    hash = "sha256-hCe2UPqrSR6u3/UxsURI2KzRxN5saeTteCRq5Zfay4M=";
  };
in
{
  age.secrets.hugochat_db_password.file = ../../secrets/hugochat_db_password.age;

  systemd.services.hugo-chat-server = {
    description = "HugoChat server, a chat platform";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    environment = {
      SPRING_DATASOURCE_URL = "jdbc:postgresql://localhost:5003/postgres";
    };
    serviceConfig = {
      DynamicUser = true;
      ExecStart = "${lib.getExe' pkgs.jdk21 "java"} -jar ${jarfile} --server.port=5001";
      EnvironmentFile = [ config.age.secrets.hugochat_db_password.path ];
    };
  };

  virtualisation.oci-containers.containers = {
    hugo-chat-db = {
      image = "postgres:16";
      ports = [ "127.0.0.1:5003:5432" ];
      volumes = [ "/var/lib/hugo-chat/data:/var/lib/postgresql/data" ];
      environment = {
        PGDATA = "/var/lib/postgresql/data/pgdata";
      };
      extraOptions = [ "--network=hugo-chat" ];
      environmentFiles = [ config.age.secrets.hugochat_db_password.path ];
    };
  };

  services.custom-backup.jobs = [
    {
      app = "hugo-chat";
      pgDump = {
        containerName = "hugo-chat-db";
        dbName = "postgres";
        userName = "postgres";
      };
    }
  ];

  # https://www.reddit.com/r/NixOS/comments/13e5w6b/does_anyone_have_a_working_nixos_ocicontainers/
  systemd.services.init-hugo-chat-podman-network = {
    description = "Create the network bridge for hugo-chat.";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      	${lib.getExe pkgs.podman} network create hugo-chat || true
      	'';
  };
  system.activationScripts.makeHugoChatDir = lib.stringAfter [ "var" ] ''
    mkdir -p /var/lib/hugo-chat/data
  '';
}
