{ config, ... }: {
  services.immich-public-proxy = {
    enable = true;
    immichUrl = "https://immich.internal.noratrieb.dev"; # redirected to wg IP via /etc/hosts
    port = 8940;
  };

  services.caddy.virtualHosts."immich-share.noratrieb.dev" = {
    extraConfig = ''
      reverse_proxy * localhost:${builtins.toString config.services.immich-public-proxy.port}
    '';
  };
}
