{ config, lib, ... }:
let
  dockerLogin = {
    registry = "docker.noratrieb.dev";
    username = "nils";
    passwordFile = config.age.secrets.docker_registry_password.path;
  };
in
{
  virtualisation.oci-containers.containers = {
    cargo-bisect-rustc-service = {
      image = "docker.noratrieb.dev/cargo-bisect-rustc-service:316a4044";
      volumes = [
        "/var/lib/cargo-bisect-rustc-service:/data"
      ];
      environment = {
        SQLITE_DB = "/data/db.sqlite";
      };
      ports = [ "127.0.0.1:5005:4000" ];
      login = dockerLogin;
    };
  };

  services.custom-backup.jobs = [
    {
      app = "cargo-bisect-rustc-service";
      file = "/var/lib/cargo-bisect-rustc-service/db.sqlite";
    }
  ];

  system.activationScripts.makeCargoBisectRustcServiceDir = lib.stringAfter [ "var" ] ''
    mkdir -p /var/lib/cargo-bisect-rustc-service/
    chmod ugo+w /var/lib/cargo-bisect-rustc-service/
  '';
}
