{ pkgs, config, name, ... }: {
  networking.firewall.allowedTCPPorts = [
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

          ${
            if name == "vps1" then
            ''
              noratrieb.dev {
                root * ${./nora}
                file_server
              }
            '' else ""
          }
        ''
      );
  };
}
