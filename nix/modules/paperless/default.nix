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
    };
    exporter = {
      enable = true;
      directory = "${nasDir}/export_minipc";
      onCalendar = "02:25:00";
    };
  };

  networking.firewall.allowedTCPPorts = [ 8010 ];
}
