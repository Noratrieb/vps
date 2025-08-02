{ config, lib, pkgs, ... }:
let
  dockerLogin = {
    registry = "docker.noratrieb.dev";
    username = "nils";
    passwordFile = config.age.secrets.docker_registry_password.path;
  };
in
{
  age.secrets.hugochat_db_password.file = ../../secrets/hugochat_db_password.age;

  virtualisation.oci-containers.containers = {
    hugo-chat-client = {
      image = "docker.noratrieb.dev/hugo-chat-client:89ce0b07";
      login = dockerLogin;
      ports = [ "127.0.0.1:5002:80" ];
    };

    hugo-chat-server = {
      image = "docker.noratrieb.dev/hugo-chat-server:89ce0b07";
      ports = [ "127.0.0.1:5001:8080" ];
      environment = {
        SPRING_DATASOURCE_URL = "jdbc:postgresql://hugo-chat-db:5432/postgres";
      };
      environmentFiles = [ config.age.secrets.hugochat_db_password.path ];
      extraOptions = [ "--network=hugo-chat" ];

      dependsOn = [ "hugo-chat-db" ];
      login = dockerLogin;
    };

    hugo-chat-db = {
      image = "postgres:16";
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
