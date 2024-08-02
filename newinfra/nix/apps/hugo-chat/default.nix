{ config, lib, ... }:
let
  dockerLogin = {
    registry = "docker.noratrieb.dev";
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
        image: "docker.noratrieb.dev/hugo-chat-client:63bd1922"
        restart: always
        ports:
          - "5002:80"
    */
    hugo-chat-client = {
      image = "docker.noratrieb.dev/hugo-chat-client:63bd1922";
      login = dockerLogin;
      ports = [ "5002:80" ];
    };
    /*
      hugo_chat_server:
        container_name: hugo-chat-server
        image: "docker.noratrieb.dev/hugo-chat-server:63bd1922"
        ports:
          - "5001:8080"
        environment:
          SPRING_DATASOURCE_URL: "jdbc:postgresql://hugo-chat-db:5432/hugochat"
          SPRING_DATASOURCE_PASSWORD: "${HUGO_CHAT_DB_PASSWORD}"
        networks:
          - hugo-chat
    */
    hugo-chat-server = {
      image = "docker.noratrieb.dev/hugo-chat-server:63bd1922";
      ports = [ "5001:80" ];
      environment = {
        SPRING_DATASOURCE_URL = "jdbc:postgresql://vps1.local:5003/hugochat";
      };
      environmentFiles = [ config.age.secrets.hugochat_db_password.path ];
      login = dockerLogin;
    };

    /*
      hugo_chat_db:
        container_name: hugo-chat-db
        image: "postgres:latest"
        restart: always
        volumes:
          - "/apps/hugo-chat/data:/var/lib/postgresql/data"
        environment:
          POSTGRES_PASSWORD: "${HUGO_CHAT_DB_PASSWORD}"
          PGDATA: "/var/lib/postgresql/data/pgdata"
        networks:
          - hugo-chat
    */
    hugo-chat-db = {
      image = "postgres:16";
      ports = [ "5003:80" ];
      volumes = [ "/var/lib/hugo-chat/data:/var/lib/postgresql/data" ];
      environment = {
        POSTGRES_PASSWORD = "\${HUGO_CHAT_DB_PASSWORD}";
        PGDATA = "/var/lib/postgresql/data/pgdata";
      };
      environmentFiles = [ config.age.secrets.hugochat_db_password.path ];
    };
  };


  system.activationScripts.makeHugoChatDir = lib.stringAfter [ "var" ] ''
    mkdir -p /var/lib/hugo-chat/data
  '';
}
