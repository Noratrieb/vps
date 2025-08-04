{ config, lib, pkgs, ... }:
let
  dockerLogin = {
    registry = "docker.noratrieb.dev";
    username = "nils";
    passwordFile = config.age.secrets.docker_registry_password.path;
  };
in
{
  age.secrets.openolat_db_password.file = ../../secrets/openolat_db_password.age;

  virtualisation.oci-containers.containers = {
    openolat = {
      image = "docker.noratrieb.dev/openolat:69b3c8b6";
      volumes = [
        "/var/lib/openolat/files:/home/openolat/olatdata"
        "${./extra-properties.properties}:/home/openolat/extra-properties.properties"
      ];
      ports = [ "127.0.0.1:5011:8088" ];
      environment = {
        # DB_PASSWORD = from openolat_db_password
        DB_URL = "jdbc:postgresql://openolat-db:5432/oodb";
        EXTRA_PROPERTIES = "/home/openolat/extra-properties.properties";
        OLAT_HOST = "olat.noratrieb.dev";
      };
      environmentFiles = [ config.age.secrets.openolat_db_password.path ];
      extraOptions = [ "--network=openolat" ];

      dependsOn = [ "openolat-db" ];
      login = dockerLogin;
    };

    openolat-db = {
      image = "postgres:15";
      volumes = [ "/var/lib/openolat/db:/var/lib/postgresql/data" ];
      environment = {
        POSTGRES_DB = "oodb";
        POSTGRES_USER = "oodbu";
        # POSTGRES_PASSWORD = from openolat_db_password
        PGDATA = "/var/lib/postgresql/data/pgdata";
      };
      extraOptions = [ "--network=openolat" ];
      environmentFiles = [ config.age.secrets.openolat_db_password.path ];
    };
  };

  services.caddy.virtualHosts = {
    "olat.noratrieb.dev" = {
      logFormat = "";
      extraConfig = ''
        encode zstd gzip
        reverse_proxy * localhost:5011
      '';
    };
    # unsure if necessary... something was misconfigured in the past here...
    "olat.noratrieb.dev:8088" = {
      logFormat = "";
      extraConfig = ''
        encode zstd gzip
        reverse_proxy * localhost:5011
      '';
    };
  };

  services.custom-backup.jobs = [
    {
      app = "openolat-db";
      pgDump = {
        containerName = "openolat-db";
        dbName = "oodb";
        userName = "oodbu";
      };
    }
  ];

  # https://www.reddit.com/r/NixOS/comments/13e5w6b/does_anyone_have_a_working_nixos_ocicontainers/
  systemd.services.init-openolat-podman-network = {
    description = "Create the network bridge for openolat.";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      	${lib.getExe pkgs.podman} network create openolat || true
      	'';
  };
  system.activationScripts.makeOpenolatDir = lib.stringAfter [ "var" ] ''
    mkdir -p /var/lib/openolat/db
    mkdir -p /var/lib/openolat/files
  '';
}
