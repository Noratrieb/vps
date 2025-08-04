{ my-projects-versions, pkgs, lib, config, ... }:
let upload-files = import (fetchTarball "https://github.com/Noratrieb/upload.files.noratrieb.dev/archive/${my-projects-versions."upload.files.noratrieb.dev"}.tar.gz"); in
{
  age.secrets.upload_files_s3_secret.file = ../../secrets/upload_files_s3_secret.age;

  systemd.services.upload-files = {
    description = "upload.files.noratrieb.dev file uploader for files.noratrieb.dev";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    environment = {
      UPLOAD_FILES_NORATRIEB_DEV_BUCKET = "files.noratrieb.dev";
      UPLOAD_FILES_NORATRIEB_DEV_ENDPOINT = "http://localhost:3900";
      UPLOAD_FILES_NORATRIEB_DEV_REGION = "garage";
    };
    serviceConfig = {
      DynamicUser = true;
      ExecStart = "${lib.getExe (upload-files {inherit pkgs;})}";
      EnvironmentFile = [ config.age.secrets.upload_files_s3_secret.path ];
    };
  };

  services.caddy.virtualHosts."upload.files.noratrieb.dev" = {
    logFormat = "";
    extraConfig = ''
      	encode zstd gzip
        # we need HTTP/2 here because the server doesn't work with HTTP/1.1
        # because it will send early 401 responses during the upload without consuming the body
        # (this has been mostly fixed but still keep it)
        reverse_proxy * h2c://localhost:3050
    '';
  };
}
