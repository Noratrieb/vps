{ pkgs, nixpkgs-unstable, config, lib, name, website, slides, blog, ... }:

let caddy = nixpkgs-unstable.caddy; in
{
  networking.firewall = {
    allowedTCPPorts = [
      80 # HTTP
      443 # HTTPS
    ];
    allowedUDPPorts = [
      443 # HTTP/3 via QUIC
    ];
  };

  services.caddy = {
    enable = true;
    package = caddy;
    configFile = pkgs.writeTextFile {
      name = "Caddyfile";
      text = (
        ''
          {
              email nilstrieb@proton.me
              auto_https disable_redirects
          }

          http:// {
            respond "This is an HTTPS-only server, silly you. Go to https:// instead." 418
          }

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
            if name == "vps1" then
            builtins.readFile ./Caddyfile + ''
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
        ''
      );
      checkPhase = ''
        ${lib.getExe caddy} --version
        ${lib.getExe caddy} validate --adapter=caddyfile --config=$out
      '';
    };
  };
}
