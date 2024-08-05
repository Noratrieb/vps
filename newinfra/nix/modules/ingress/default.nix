{ pkgs, config, lib, name, website, slides, blog, ... }: {
  networking.firewall.allowedTCPPorts = [
    443
  ];

  services.caddy = {
    enable = true;
    configFile = pkgs.writeTextFile {
      name = "Caddyfile";
      text = (
        ''
          {
              email nilstrieb@proton.me
          }

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
      checkPhase = ''
        ${lib.getExe pkgs.caddy} validate --adapter=caddyfile --config=$out
      '';
    };
  };
}
