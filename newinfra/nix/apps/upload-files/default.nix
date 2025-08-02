{ upload-files, pkgs, lib, config, ... }: {
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
}
