{ pkgs, config, lib, name, ... }:

let
  caddy = pkgs.caddy.withPlugins {
    plugins = [
      "github.com/noratrieb-mirrors/certmagic-s3@v1.1.3"
      "github.com/sagikazarmark/caddy-fs-s3@v0.10.0"
    ];
    hash = "sha256-mBoHjvx7vcWepF4PdPqmHjoYrnCl487CD02kk9VeJWM=";
  };
in
{
  environment.systemPackages = [ caddy ];

  networking.firewall.interfaces.wg0.allowedTCPPorts = [ 9010 ]; # metrics

  networking.firewall = {
    allowedTCPPorts = [
      80 # HTTP
      443 # HTTPS
    ];
    allowedUDPPorts = [
      443 # HTTP/3 via QUIC
    ];
  };

  age.secrets.caddy_s3_key_secret.file = ../../secrets/caddy_s3_key_secret.age;

  systemd.services.caddy.serviceConfig.EnvironmentFile = [ config.age.secrets.caddy_s3_key_secret.path ];
  systemd.services.caddy.after = [ "garage.service" ]; # the cert store depends on garage
  services.caddy = {
    enable = true;
    package = caddy;
    logFormat = ''
      output stdout
      format json
    '';
    globalConfig = ''
      email tls@noratrieb.dev
      auto_https disable_redirects

      storage s3 {
        host "localhost:3900"
        bucket "caddy-store"
        # access_id ENV S3_ACCESS_ID
        # secret_key ENV S3_SECRET_KEY

        insecure true
      }

      servers {
        metrics
      }
    '';
    virtualHosts = {
      "http://" = {
        logFormat = "";
        extraConfig = ''
          respond "This is an HTTPS-only server, silly you. Go to https:// instead." 418
        '';
      };
      ":9010" = {
        logFormat = "output discard";
        extraConfig = ''
          metrics /metrics
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
