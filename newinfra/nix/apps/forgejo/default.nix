{ config, ... }: {
  age.secrets.forgejo_s3_key_secret.file = ../../secrets/forgejo_s3_key_secret.age;


  services.forgejo = {
    enable = true;
    database = {
      type = "sqlite3";
    };
    lfs.enable = false;

    settings = {
      DEFAULT = {
        APP_NAME = "this forge meows";
        APP_SLOGAN = "this forge meows";
      };

      server = rec {
        DOMAIN = "git.noratrieb.dev";
        ROOT_URL = "https://${DOMAIN}/";
        HTTP_PORT = 5015;
      };

      service = {
        DISABLE_REGISTRATION = true;
      };

      storage = {
        STORAGE_TYPE = "minio";
        MINIO_ENDPOINT = "127.0.0.1:3900";
        MINIO_ACCESS_KEY_ID = "GKc8bfd905eb7f85980ffe84c9";
        MINIO_BUCKET = "forgejo";
        MINIO_BUCKET_LOOKUP = "auto";
        MINIO_LOCATION = "garage";
        MINIO_USE_SSL = false;
      };
    };

    secrets = {
      storage = {
        MINIO_SECRET_ACCESS_KEY = config.age.secrets.forgejo_s3_key_secret.path;
      };
    };
  };

  services.custom-backup.jobs = [{
    app = "forgejo";
    file = "/var/lib/forgejo/data/forgejo.db";
  }];
}
