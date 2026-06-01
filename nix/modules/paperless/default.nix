{ config, ... }:
let nasDir = "/mnt/nas/HEY/_Nora/paperless"; in {
  age.secrets.paperless_env.file = ../../secrets/paperless_env.age;

  services.paperless = {
    enable = true;
    consumptionDir = "${nasDir}/consume";
    address = "0.0.0.0";
    port = 8010;
    environmentFile = config.age.secrets.paperless_env.path;
    settings = {
      PAPERLESS_TIME_ZONE = "Europe/Zurich";
      PAPERLESS_ADMIN_USER = "nora";
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
      PAPERLESS_URL = "https://paperless.internal.noratrieb.dev";
    };
    exporter = {
      enable = true;
      directory = "${nasDir}/export_minipc";
      onCalendar = "02:25:00";
    };
  };

  services.caddy.virtualHosts."paperless.internal.noratrieb.dev" = {
    extraConfig = ''
      tls {
        dns_challenge_override_domain "_acme-challenge.paperless.internal.noratrieb-acme-delegate.dev"
      }
      reverse_proxy * localhost:${builtins.toString config.services.paperless.port}
    '';
  };

  networking.firewall.allowedTCPPorts = [ config.services.paperless.port ];
}
