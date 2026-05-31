{ pkgs, config, lib, name, ... }: {
  imports = [ ../caddy-base ];

  age.secrets.caddy_s3_key_secret.file = ../../secrets/caddy_s3_key_secret.age;

  systemd.services.caddy.serviceConfig.EnvironmentFile = [ config.age.secrets.caddy_s3_key_secret.path ];
  systemd.services.caddy.after = [ "garage.service" ]; # the cert store depends on garage
  services.caddy = {
    globalConfig = ''
      storage s3 {
        host "localhost:3900"
        bucket "caddy-store"
        # access_id ENV S3_ACCESS_ID
        # secret_key ENV S3_SECRET_KEY

        insecure true
      }
    '';
    virtualHosts = {
      "http://" = {
        logFormat = "";
        extraConfig = ''
          respond "This is an HTTPS-only server, silly you. Go to https:// instead." 418
        '';
      };
      "${name}.infra.noratrieb.dev" = {
        logFormat = "";
        extraConfig = ''
          encode zstd gzip
          header -Last-Modified
          root * ${import ../../packages/caddy-static-prepare {
            name = "debugging-page";
            src = ./debugging-page;
            inherit pkgs lib;
          }}
          file_server {
            etag_file_extensions .sha256
            precompressed zstd gzip br
          }
        '';
      };
    };
  };
}
