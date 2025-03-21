{ config, ... }: {
  age.secrets.forgejo_s3_key_secret.file = ../../secrets/forgejo_s3_key_secret.age;
  age.secrets.mail_git_password.file = ../../secrets/mail_git_password.age;

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

      mailer = {
        ENABLED = true;
        FROM = "\"Nora's Git Server\" <git@git.noratrieb.dev>";
        PROTOCOL = "smtp+starttls";
        SMTP_ADDR = "localhost";
        SMTP_PORT = 587;
        USER = "git@git.noratrieb.dev";
        PASSWD = "Meowmeow";
        FORCE_TRUST_SERVER_CERT = true; # lol. it's localhost.

        /*ENABLED = true;
        PROTOCOL = "sendmail";
        FROM = "git@git.noratrieb.dev";
        SENDMAIL_PATH = lib.getExe pkgs.system-sendmail;
        SENDMAIL_ARGS = "--"; # most "sendmail" programs take options, "--" will prevent an email address being interpreted as an option.
        */
      };
    };

    secrets = {
      storage = {
        MINIO_SECRET_ACCESS_KEY = config.age.secrets.forgejo_s3_key_secret.path;
      };
      mailer = {
        # PASSWD = config.age.secrets.mail_git_password.path;
      };
    };
  };

  services.custom-backup.jobs = [{
    app = "forgejo";
    file = "/var/lib/forgejo/data/forgejo.db";
  }];
}
