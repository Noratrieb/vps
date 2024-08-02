{ pkgs, config, name, website, slides, blog, ... }: {
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
              nilstrieb.dev {
                redir https://noratrieb.dev{uri} permanent
              }

              blog.nilstrieb.dev {
                redir https://blog.noratrieb.dev{uri} permanent
              }

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
