{ pkgs, config, ... }: {
  networking.firewall.allowedTCPPorts = [
    22
    443
  ];

  services.caddy = {
    enable = true;
    configFile = pkgs.writeText "Caddyfile"
      (
        builtins.readFile ./Caddyfile +
        ''
          ${config.networking.hostName}.infra.noratrieb.dev {
            root * ${./debugging-page}
            file_server
          }
        ''
      );
  };
}
