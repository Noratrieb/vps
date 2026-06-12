{ config, pkgs, lib, ... }: {
  age.secrets.hedgedoc_env.file = ../../secrets/hedgedoc_env.age;

  services.hedgedoc = {
    enable = true;
    environmentFile = config.age.secrets.hedgedoc_env.path
    ;
    settings = {
      domain = "hedgedoc.noratrieb.dev";
      allowAnonymous = false;
      allowAnonymousEdits = false;
      protocolUseSSL = true;
      enableUploads = "registered";
      allowEmailRegister = false;
      #imageuploadtype = "minio";
      # doesn't work yet :(
      minio = {
        accessKey = "GK23559653411395bd9f29dd70";
        endPoint = "localhost";
        port = 3900;
        secure = false;
      };
      s3bucket = "hedgedoc";
    };
  };

  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "hedgedoc-manage_users";
      text = ''
        CMD_DB_URL="sqlite://${config.services.hedgedoc.settings.db.storage}" ${lib.getExe' pkgs.hedgedoc "manage_users"} "$@"
      '';
    })
    (pkgs.writeShellApplication {
      name = "hedgedoc-db";
      text = ''
        ${lib.getExe pkgs.rlwrap} --always-readline ${lib.getExe pkgs.sqlite-interactive} ${config.services.hedgedoc.settings.db.storage}
      '';
    })
  ];

  services.caddy.virtualHosts = {
    "hedgedoc.noratrieb.dev" = {
      logFormat = "";
      extraConfig = ''
        encode zstd gzip
        reverse_proxy * localhost:${builtins.toString config.services.hedgedoc.settings.port}
      '';
    };
  };
}
