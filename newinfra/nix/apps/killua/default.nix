{ config, lib, ... }:
let dataDir = "/var/lib/killua"; in
{
  age.secrets.killua_env.file = ../../secrets/killua_env.age;

  virtualisation.oci-containers.containers = {
    killua = {
      image = "docker.noratrieb.dev/killua-bot:ac8203d2";
      volumes = [
        "${dataDir}:/data"
      ];
      environment = {
        KILLUA_JSON_PATH = "/data/trivia_questions.json";
      };
      environmentFiles = [ config.age.secrets.killua_env.path ];
      login = {
        registry = "docker.noratrieb.dev";
        username = "nils";
        passwordFile = config.age.secrets.docker_registry_password.path;
      };
    };
  };

  services.custom-backup.jobs = [
    {
      app = "killua";
      file = "${dataDir}/trivia_questions.json";
    }
  ];

  system.activationScripts.makeKilluaDir = lib.stringAfter [ "var" ] ''
    mkdir -p ${dataDir}
    chmod ugo+w ${dataDir}
  '';
}
