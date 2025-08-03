{ config, lib, pkgs, ... }:
let
  jarfile = pkgs.fetchurl {
    url =
      "https://github.com/Noratrieb/killua-bot/releases/download/2023-08-26/KilluaBot.jar";
    hash = "sha256-LUABYq6cRhLTLyZVzkIjIFHERcb7YQTzyAGaJB49Mxk=";
  };
  dataDir = "/var/lib/killua";
in
{
  age.secrets.killua_env.file = ../../secrets/killua_env.age;

  systemd.services.killua = {
    description = "killua, an awesome discord bot";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    environment = {
      BOT_TOKEN_PATH = config.age.secrets.widetom_bot_token.path;
      CONFIG_PATH = config.age.secrets.widetom_config_toml.path;
    };
    serviceConfig = {
      DynamicUser = true;
      ExecStart = "${lib.getExe' pkgs.jdk17 "java"} -jar ${jarfile}";
      EnvironmentFile = [ config.age.secrets.killua_env.path ];
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
