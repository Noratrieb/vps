{ pkgs, config, lib, name, website, slides, blog, ... }:

let
  caddy = pkgs.callPackage ./caddy-build.nix {
    externalPlugins = [
      {
        name = "certmagic-s3";
        repo = "github.com/noratrieb-mirrors/certmagic-s3";
        version = "e48519f95173e982767cbb881d49335b6a00a599";
      }
    ];
    vendorHash = "sha256-KP9bYitM/Pocw4DxOXPVBigWh4IykNf8yKJiBlTFZmI=";
  };
in
{
  environment.systemPackages = [ caddy ];

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

  systemd.services.caddy.serviceConfig.EnvironmentFile = config.age.secrets.caddy_s3_key_secret.path;
  services.caddy = {
    enable = true;
    package = caddy;
    configFile = pkgs.writeTextFile {
      name = "Caddyfile";
      text = (
        builtins.readFile ./base.Caddyfile +
        ''
          ${config.networking.hostName}.infra.noratrieb.dev {
              encode zstd gzip
              header -Last-Modified
              root * ${import ./caddy-static-prepare {
                name = "debugging-page";
                src = ./debugging-page;
                inherit pkgs lib;
              }}
              file_server {
                  etag_file_extensions .sha256
                  precompressed zstd gzip br
              }
          }

          ${
            if name == "vps1" || name == "vps3" || name == "vps4" then ''
            noratrieb.dev {
                encode zstd gzip
                header -Last-Modified
                root * ${import ./caddy-static-prepare {
                  name = "website";
                  src = website { inherit pkgs slides blog; };
                  inherit pkgs lib;
                }}
                file_server {
                    etag_file_extensions .sha256
                    precompressed zstd gzip br
                }
            }
            '' else ""
          }

          ${
            if name == "vps1" then
            builtins.readFile ./Caddyfile else ""
          }
        ''
      );
      checkPhase = ''
        ${lib.getExe caddy} --version
        ${lib.getExe caddy} validate --adapter=caddyfile --config=$out
      '';
    };
  };
}
