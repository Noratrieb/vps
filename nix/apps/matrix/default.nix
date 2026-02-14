{ pkgs, ... }: {
  services.matrix-continuwuity = {
    enable = true;
    settings = {
      global = {
        server_name = "noratrieb.dev";
        allow_registration = false;
        allow_encryption = true;
        allow_federation = true;
        trusted_servers = [ "matrix.org" ];
        well_known = {
          server = "matrix.noratrieb.dev:443";
          client = "https://matrix.noratrieb.dev";
          support_page = "https://noratrieb.dev";
        };
      };
    };
  };
  environment.systemPackages = [ pkgs.matrix-continuwuity ];
  services.caddy.virtualHosts."matrix.noratrieb.dev" = {
    extraConfig = ''
      encode zstd gzip

      reverse_proxy * http://localhost:6167
    '';
  };
  services.caddy.virtualHosts."matrix.noratrieb.dev:8448" = {
    extraConfig = ''
      encode zstd gzip

      reverse_proxy * http://localhost:6167
    '';
  };
  networking.firewall.allowedTCPPorts = [ 8448 ];
  networking.firewall.interfaces.wg0.allowedTCPPorts = [ 6167 ];
}
