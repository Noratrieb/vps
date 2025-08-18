{ pkgs, lib, my-projects-versions, ... }:
let
  does-it-build-base = (import (pkgs.fetchFromGitHub my-projects-versions.does-it-build.fetchFromGitHub)) { inherit pkgs; };
  does-it-build = does-it-build-base.overrideAttrs (finalAttrs: previousAttrs: {
    DOES_IT_BUILD_OVERRIDE_VERSION = my-projects-versions.does-it-build.commit;
    RUSTFLAGS = "-Cforce-frame-pointers=true";
  });
in
{
  services.caddy.virtualHosts = {
    "does-it-build.noratrieb.dev" = {
      logFormat = "";
      extraConfig = ''
        @blocked {
          header User-Agent *SemrushBot*
          header User-Agent *AhrefsBot*
          header User-Agent *Amazonbot*
          header User-Agent *openai.com*
        }

        respond @blocked "get fucked" 418

        encode zstd gzip
        reverse_proxy * localhost:3000
      '';
    };
  };

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

  services.custom-backup-restic.jobs = [{
    app = "does-it-build";
    path = "/var/lib/does-it-build/db.sqlite";
  }];

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
