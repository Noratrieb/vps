{ config, ... }: {
  age.secrets.minio_env_file.file = ../../secrets/minio_env_file.age;

  services.minio = {
    enable = true;
    region = "eu";
    rootCredentialsFile = config.age.secrets.minio_env_file.path;
  };
}
