{ pkgs, ... }: {
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
          vps1.nilstrieb.dev {
            root * ${./debugging-page}
            file_server
          }
        ''
      );
  };
}
