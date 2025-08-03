{ config, pkgs, lib, my-projects-versions, ... }:
let
  widetom = pkgs.rustPlatform.buildRustPackage {
    src = pkgs.fetchFromGitHub {
      owner = "Noratrieb";
      repo = "widetom";
      rev = my-projects-versions.widetom;
      hash = "sha256-lSjlDozwKRLF62jsDaWo+8+rcQdeEgurEnuw00hk3o8=";
    };
    pname = "widetom";
    version = "0.1.0";
    cargoHash = "sha256-AWbdPcDc+QOW7U/FYbqlIsg+3MwfggKCTCw1z/ZbSEE=";
    meta = {
      mainProgram = "widertom";
    };
  };
in
{
  age.secrets.widetom_bot_token = {
    file = ../../secrets/widetom_bot_token.age;
    owner = config.users.users.widetom.name;
  };
  age.secrets.widetom_config_toml = {
    file = ../../secrets/widetom_config_toml.age;
    owner = config.users.users.widetom.name;
  };

  systemd.services.widetom = {
    description = "widetom, the extremely funny discord bot";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    environment = {
      BOT_TOKEN_PATH = config.age.secrets.widetom_bot_token.path;
      CONFIG_PATH = config.age.secrets.widetom_config_toml.path;
    };
    serviceConfig = {
      DynamicUser = true;
      ExecStart = lib.getExe widetom;
    };
  };

  users.users.widetom = {
    group = "widetom";
    isSystemUser = true;
  };
  users.groups.widetom = { };
}
