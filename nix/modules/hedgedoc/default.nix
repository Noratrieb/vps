{ config, ... }: {
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
