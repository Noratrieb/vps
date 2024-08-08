{ config, lib, pkgs, ... }: with lib;
let
  jobOptions = { ... }: {
    options = {
      app = mkOption {
        type = types.str;
        description = "The app name, used as the directory in the bucket";
      };
      environmentFile = mkOption {
        type = types.nullOr types.path;
        default = null;
      };
      file = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      pgDump = mkOption {
        type = types.nullOr (types.submodule ({ ... }: {
          options = {
            containerName = mkOption {
              type = types.str;
            };
            dbName = mkOption {
              type = types.str;
            };
            userName = mkOption {
              type = types.str;
            };
          };
        }));
        default = null;
      };
      #mongo_dump = { };
    };
  };
in
{
  options.services.custom-backup = {
    jobs = mkOption {
      default = [ ];
      type = types.listOf (types.submodule jobOptions);
      description = "Backup jobs to execute";
    };
  };

  config =
    let
      cfg = config.services.custom-backup;
      backupConfig = {
        files = builtins.map (job: { app = job.app; file = job.file; })
          (builtins.filter (job: job.file != null) cfg.jobs);
        pg_dumps = builtins.map (job: { app = job.app; } // job.pgDump)
          (builtins.filter (job: job.pgDump != null) cfg.jobs);
      };
      backupScript = pkgs.writeShellApplication {
        name = "backup";
        runtimeInputs = with pkgs; [ podman jq minio-client getent xz ];
        text = builtins.readFile ./backup.sh;
      };
    in
    {
      age.secrets.backup_s3_secret.file = ../../secrets/backup_s3_secret.age;

      systemd.services.custom-backup = {
        startAt = "daily";
        serviceConfig = {
          # TODO: can we use a dynamic user?
          #DynamicUser = true;
          ExecStart = "${backupScript}/bin/backup";
          Environment = [
            "CONFIG_FILE=${pkgs.writeText "backup-config.json" (builtins.toJSON backupConfig)}"
            "S3_BUCKET=backups"
            "S3_ENDPOINT=http://localhost:3900"
          ];
          EnvironmentFile = (builtins.filter (file: file != null)
            (builtins.map (job: job.environmentFile) cfg.jobs)) ++ [
            config.age.secrets.backup_s3_secret.path
          ];
        };
      };
    };
}

