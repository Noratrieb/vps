{ pkgs, ... }:
let
  caddy = pkgs.caddy.withPlugins {
    plugins = [
      "github.com/noratrieb-mirrors/certmagic-s3@v1.1.3"
      "github.com/sagikazarmark/caddy-fs-s3@v0.10.0"
      "github.com/caddy-dns/rfc2136@v1.0.0"
    ];
    hash = "sha256-m5RHlrheqzoGqKQxixq+xTd2hlnCTets9zCT7aFka8g=";
  };
in
{
  environment.systemPackages = [ pkgs.caddy ];

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

  services.caddy = {
    enable = true;
    package = caddy;
    logFormat = ''
      output stdout
      format json
    '';
    globalConfig = ''
      auto_https disable_redirects

      servers {
        metrics
      }
    '';
    virtualHosts = {
      ":9010" = {
        logFormat = "output discard";
        extraConfig = ''
          metrics /metrics
        '';
      };
    };
  };
}
