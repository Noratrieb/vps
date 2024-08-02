{ lib, config, ... }: {
  virtualisation.oci-containers.containers.uptime = {
    /*
      uptime:
      container_name: uptime
      image: "docker.noratrieb.dev/uptime:50d15bc4"
      restart: always
      volumes:
        - "/apps/uptime:/app/config"
      environment:
        UPTIME_CONFIG_PATH: /app/config/uptime.json
      ports:
        - "5010:3000"
    */

    image = "docker.noratrieb.dev/uptime:50d15bc4";
    volumes = [
      "${./uptime.json}:/uptime.json"
      "/var/lib/uptime:/data"
    ];
    environment = {
      UPTIME_CONFIG_PATH = "/uptime.json";
    };
    ports = [ "5010:3000" ];
    login = {
      registry = "docker.noratrieb.dev";
      username = "nils";
      passwordFile = config.age.secrets.docker_registry_password.path;
    };
  };

  system.activationScripts.makeUptimeDir = lib.stringAfter [ "var" ] ''
    mkdir -p /var/lib/uptime/
  '';
}
