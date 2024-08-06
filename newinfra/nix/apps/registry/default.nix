{ config, lib, ... }: {
  age.secrets = {
    registry_htpasswd = {
      file = ../../secrets/registry_htpasswd.age;
      owner = config.users.users.docker-registry.name;
    };
    registry_s3_key_secret = {
      file = ../../secrets/registry_s3_key_secret.age;
      owner = config.users.users.docker-registry.name;
    };
  };

  systemd.services.docker-registry.serviceConfig.EnvironmentFile = config.age.secrets.registry_s3_key_secret.path;
  services.dockerRegistry = {
    enable = true;
    storagePath = null;
    port = 5000;
    extraConfig = {
      log = {
        accesslog.disabled = false;
        level = "info";
        formatter = "text";
        fields.service = "registry";
      };
      redis = lib.mkForce null;
      storage = {
        s3 = {
          regionendpoint = "http://127.0.0.1:3900";
          region = "garage";
          bucket = "docker-registry";
          # accesskey = ""; ENV REGISTRY_STORAGE_S3_ACCESSKEY
          # secretkey = ""; ENV REGISTRY_STORAGE_S3_SECRETKEY
          secure = false;
        };
        redirect.disable = true;
      };
      http = {
        host = "https://docker.noratrieb.dev";
        draintimeout = "60s";
      };
      auth.htpasswd = {
        # TODO: ugh :(
        realm = "nilstrieb-registry";
        path = config.age.secrets.registry_htpasswd.path;
      };
    };
  };
}
