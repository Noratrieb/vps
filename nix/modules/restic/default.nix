{ config, lib, ... }: with lib;
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
      path = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      dynamicFilesFrom = mkOption {
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
  options.services.custom-backup-restic = {
    jobs = mkOption {
      default = [ ];
      type = types.listOf (types.submodule jobOptions);
      description = "Backup jobs to execute";
    };
  };

  config = {
    age.secrets.restic_backup.file = ../../secrets/restic_backup.age;
    age.secrets.generic_backup_password.file = ../../secrets/generic_backup_password.age;

    services.restic.backups =
      builtins.listToAttrs (map
        (job: {
          name = job.app;
          value = {
            paths = if job.path != null then [ job.path ] else null;
            dynamicFilesFrom = job.dynamicFilesFrom;
            initialize = true;
            timerConfig = {
              OnCalendar = "00:00";
              RandomizedDelaySec = "5h";
            };
            passwordFile = config.age.secrets.generic_backup_password.path;
            repository = "s3:http://localhost:3900/backups-restic/${job.app}";
            environmentFile = config.age.secrets.restic_backup.path;
          };
        })
        config.services.custom-backup-restic.jobs);
  };
}

