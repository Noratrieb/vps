{ config, lib, pkgs, ... }: with lib;
let
  jobOptions = { ... }: {
    options = {
      app = mkOption {
        type = types.string;
        description = "The app name, used as the directory in the bucket";
      };
      environmentFile = mkOption {
        type = types.nullOr types.path;
        default = null;
      };
      file = mkOption {
        type = types.string;
      };
      #pg_dump = { };
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
      };
      backupScript = pkgs.writeShellApplication {
        name = "backup";
        runtimeInputs = with pkgs; [ jq minio-client getent xz ];
        text = builtins.readFile ./backup.sh;
      };
    in
    {
      age.secrets.backup_s3_secret.file = ../../secrets/backup_s3_secret.age;

      systemd.services.custom-backup = {
        startAt = "daily";
        serviceConfig = {
          DynamicUser = true;
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

