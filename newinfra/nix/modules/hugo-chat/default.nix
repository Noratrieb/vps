{ config, ... }:
let
  dockerLogin = {
    registry = "docker.nilstrieb.dev";
    username = "nils";
    passwordFile = config.age.secrets.docker_registry_password.path;
  };
in
{
  age.secrets.hugochat_db_password.file = ../../secrets/hugochat_db_password.age;

  virtualisation.oci-containers.containers = {
    /*
      hugo_chat_client:
        container_name: hugo-chat-client
        image: "docker.nilstrieb.dev/hugo-chat-client:63bd1922"
        restart: always
        ports:
          - "5002:80"
    */
    hugo-chat-client = {
      image = "docker.nilstrieb.dev/hugo-chat-client:63bd1922";
      login = dockerLogin;
      ports = [ "5002:80" ];
    };
    /*
      hugo_chat_server:
        container_name: hugo-chat-server
        image: "docker.nilstrieb.dev/hugo-chat-server:63bd1922"
        ports:
          - "5001:8080"
        environment:
          SPRING_DATASOURCE_URL: "jdbc:postgresql://hugo-chat-db:5432/hugochat"
          SPRING_DATASOURCE_PASSWORD: "${HUGO_CHAT_DB_PASSWORD}"
        networks:
          - hugo-chat
    */
    hugo-chat-server = {
      image = "docker.nilstrieb.dev/hugo-chat-server:63bd1922";
      ports = [ "5001:80" ];
      environment = {
        SPRING_DATASOURCE_URL = "jdbc:postgresql://vps1.local:5432/hugochat";
      };
      environmentFiles = [ config.age.secrets.hugochat_db_password.path ];
      login = dockerLogin;
    };
    /*
      POSTGRES_PASSWORD: "${HUGO_CHAT_DB_PASSWORD}"
      PGDATA: "/var/lib/postgresql/data/pgdata"
    */

    services.postgresql.ensureDatabases = [ "hugochat" ];
  };
}
