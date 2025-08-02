{ config, ... }: {
  age.secrets.widetom_bot_token.file = ../../secrets/widetom_bot_token.age;
  age.secrets.widetom_config_toml.file = ../../secrets/widetom_config_toml.age;

  virtualisation.oci-containers.containers = {
    /*
      container_name: widetom
      image: "docker.noratrieb.dev/widetom:33d17387"
      restart: always
      volumes:
        - "/apps/widetom:/app/config"
      environment:
        CONFIG_PATH: /app/config/config.toml
        BOT_TOKEN_PATH: /app/config/bot_token
    */
    widetom = {
      image = "docker.noratrieb.dev/widetom:33d17387";
      volumes = [
        "${config.age.secrets.widetom_config_toml.path}:/config.toml"
        "${config.age.secrets.widetom_bot_token.path}:/token"
      ];
      environment = {
        CONFIG_PATH = "/config.toml";
        BOT_TOKEN_PATH = "/token";
      };
      login = {
        registry = "docker.noratrieb.dev";
        username = "nils";
        passwordFile = config.age.secrets.docker_registry_password.path;
      };
    };
  };
}
