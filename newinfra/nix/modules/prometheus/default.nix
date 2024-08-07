{ config, ... }: {
  services.prometheus = {
    enable = true;
    globalConfig = { };
    scrapeConfigs = [
      {
        job_name = "prometheus";
        static_configs = [
          { targets = [ "localhost:9090" ]; }
        ];
      }
      {
        job_name = "node";
        static_configs = [
          { targets = [ "dns1.local:9100" ]; }
          { targets = [ "dns2.local:9100" ]; }
          { targets = [ "vps1.local:9100" ]; }
          { targets = [ "vps3.local:9100" ]; }
          { targets = [ "vps4.local:9100" ]; }
          { targets = [ "vps5.local:9100" ]; }
        ];
      }
      {
        job_name = "caddy";
        static_configs = [
          { targets = [ "vps1.local:9010" ]; }
          { targets = [ "vps3.local:9010" ]; }
          { targets = [ "vps4.local:9010" ]; }
          { targets = [ "vps5.local:9010" ]; }
        ];
      }
      {
        job_name = "docker-registry";
        static_configs = [
          { targets = [ "vps1.local:9011" ]; }
        ];
      }
      {
        job_name = "garage";
        static_configs = [
          { targets = [ "vps1.local:3903" ]; }
          { targets = [ "vps3.local:3903" ]; }
          { targets = [ "vps4.local:3903" ]; }
          { targets = [ "vps5.local:3903" ]; }
        ];
      }
      {
        job_name = "knot";
        static_configs = [
          { targets = [ "dns1.local:9433" ]; }
          { targets = [ "dns2.local:9433" ]; }
        ];
      }
    ];
  };

  age.secrets.grafana_admin_password.file = ../../secrets/grafana_admin_password.age;

  systemd.services.grafana.serviceConfig.EnvironmentFile = config.age.secrets.grafana_admin_password.path;
  services.grafana = {
    enable = true;
    settings = {
      security = {
        admin_user = "admin";
      };
      server = {
        root_url = "https://grafana.noratrieb.dev";
      };
    };

    provision = {
      enable = true;
      datasources.settings = {
        apiVersion = 1;
        datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            access = "proxy";
            url = "http://vps3.local:9090";
            jsonData = {
              httpMethod = "POST";
              prometheusType = "Prometheus";
            };
          }
        ];
      };
    };
  };
}
