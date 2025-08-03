{ pkgs, lib, my-projects-versions, ... }:
let
  does-it-build-base = (import (fetchTarball "https://github.com/Noratrieb/does-it-build/archive/${my-projects-versions.does-it-build}.tar.gz")) { inherit pkgs; };
  does-it-build = does-it-build-base.overrideAttrs (finalAttrs: previousAttrs: {
    DOES_IT_BUILD_OVERRIDE_VERSION = my-projects-versions.does-it-build;
  });
in
{
  systemd.services.does-it-build = {
    description = "https://github.com/Noratrieb/does-it-build";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    path = with pkgs; [ rustup gcc bash ];

    serviceConfig = {
      User = "does-it-build";
      Group = "does-it-build";
      ExecStart = "${lib.getExe' (does-it-build) "does-it-build" }";
      Environment = "DB_PATH=/var/lib/does-it-build/db.sqlite";
    };
  };

  services.custom-backup.jobs = [
    {
      app = "does-it-build";
      file = "/var/lib/does-it-build/db.sqlite";
    }
  ];

  users.users.does-it-build = {
    isSystemUser = true;
    home = "/var/lib/does-it-build";
    description = "does-it-build builder account";
    group = "does-it-build";
  };
  users.groups.does-it-build = { };

  # TODO: i feel like there's gotta be a better way to do the chown..
  system.activationScripts.makeDoesItBuildDir = lib.stringAfter [ "var" ] ''
    mkdir -p /var/lib/does-it-build/
    chown does-it-build:does-it-build /var/lib/does-it-build/
  '';
}
