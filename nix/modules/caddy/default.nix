{ pkgs, config, lib, name, my-projects-versions, ... }:

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
  website = import (fetchTarball "https://github.com/Noratrieb/website/archive/${my-projects-versions.website}.tar.gz");
  blog = fetchTarball "https://github.com/Noratrieb/blog/archive/${my-projects-versions.blog}.tar.gz";
  slides = fetchTarball "https://github.com/Noratrieb/slides/archive/${my-projects-versions.slides}.tar.gz";
  website-build = website { inherit pkgs slides blog; };
  hugo-chat-client = fetchTarball {
    url =
      "https://github.com/C0RR1T/HugoChat/releases/download/2024-08-05/hugo-client.tar.xz";
    sha256 = "sha256:121ai8q6bm7gp0pl1ajfk0k2nrfg05zid61i20z0j5gpb2qyhsib";
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

  systemd.services.caddy.serviceConfig.EnvironmentFile = config.age.secrets.caddy_s3_key_secret.path;
  systemd.services.caddy.after = [ "garage.service" ]; # the cert store depends on garage
  services.caddy = {
    enable = true;
    package = caddy;
    configFile = pkgs.writeTextFile {
      name = "Caddyfile";
      text = (
        builtins.readFile ./base.Caddyfile +
        ''
          ${config.networking.hostName}.infra.noratrieb.dev {
              log
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
                log
                encode zstd gzip
                header -Last-Modified
                root * ${import ./caddy-static-prepare {
                  name = "website";
                  src = website-build;
                  inherit pkgs lib;
                }}
                file_server {
                    etag_file_extensions .sha256
                    precompressed zstd gzip br
                }
            }

            files.noratrieb.dev {
              log
              encode zstd gzip

              reverse_proxy * localhost:3902
            }
            '' else ""
          }

          ${if name == "vps1" then ''
            hugo-chat.noratrieb.dev {
              log
              encode zstd gzip
              root * ${import ./caddy-static-prepare {
                name = "hugo-chat-client";
                src = hugo-chat-client;
                inherit pkgs lib;
              }}
              try_files {path} /index.html
              file_server {
                etag_file_extensions .sha256
                precompressed zstd gzip br
              }
            }
          '' else ""}

          ${
            if name == "vps1" || name == "vps3" || name == "vps4" then
            builtins.readFile ./${name}.Caddyfile else ""
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
