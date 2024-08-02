{ pkgs, config, name, website, slides, blog, ... }: {
  networking.firewall.allowedTCPPorts = [
    443
  ];

  services.caddy = {
    enable = true;
    configFile = pkgs.writeText "Caddyfile"
      (
        ''
          ${config.networking.hostName}.infra.noratrieb.dev {
            root * ${./debugging-page}
            file_server
          }

          ${
            if name == "vps1" then
            builtins.readFile ./Caddyfile + ''
              noratrieb.dev {
                root * ${website {inherit pkgs slides blog;}}
                file_server
              }
            '' else ""
          }
        ''
      );
  };
}
