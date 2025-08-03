{ config, lib, ... }: {
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
          { targets = [ "vps2.local:9100" ]; }
          { targets = [ "vps3.local:9100" ]; }
          { targets = [ "vps4.local:9100" ]; }
          { targets = [ "vps5.local:9100" ]; }
        ];
      }
      {
        job_name = "cadvisor";
        static_configs = [
          { targets = [ "dns1.local:8080" ]; }
          { targets = [ "dns2.local:8080" ]; }
          { targets = [ "vps1.local:8080" ]; }
          { targets = [ "vps2.local:8080" ]; }
          { targets = [ "vps3.local:8080" ]; }
          { targets = [ "vps4.local:8080" ]; }
          { targets = [ "vps5.local:8080" ]; }
        ];
      }
      {
        job_name = "systemd";
        static_configs = [
          { targets = [ "dns1.local:9558" ]; }
          { targets = [ "dns2.local:9558" ]; }
          { targets = [ "vps1.local:9558" ]; }
          { targets = [ "vps2.local:9558" ]; }
          { targets = [ "vps3.local:9558" ]; }
          { targets = [ "vps4.local:9558" ]; }
          { targets = [ "vps5.local:9558" ]; }
        ];
      }
      {
        job_name = "caddy";
        static_configs = [
          { targets = [ "vps1.local:9010" ]; }
          { targets = [ "vps2.local:9010" ]; }
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
          { targets = [ "vps2.local:3903" ]; }
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
      {
        job_name = "pretense";
        static_configs = [
          { targets = [ "dns1.local:9150" ]; }
          { targets = [ "dns2.local:9150" ]; }
          { targets = [ "vps1.local:9150" ]; }
          { targets = [ "vps2.local:9150" ]; }
          { targets = [ "vps3.local:9150" ]; }
          { targets = [ "vps4.local:9150" ]; }
          { targets = [ "vps5.local:9150" ]; }
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
          {
            name = "loki";
            type = "loki";
            access = "proxy";
            url = "http://vps3.local:3100";
          }
        ];
      };
    };
  };

  networking.firewall.interfaces.wg0.allowedTCPPorts = [ 3100 ]; # loki
  age.secrets.loki_env.file = ../../secrets/loki_env.age;
  systemd.services.loki.serviceConfig.EnvironmentFile = config.age.secrets.loki_env.path;
  services.loki = {
    enable = true;
    extraFlags = [ "-config.expand-env=true" /*"-print-config-stderr"*/ ];
    configuration = {
      auth_enabled = false;
      server = {
        http_listen_port = 3100;
      };
      common = {
        ring = {
          instance_addr = "127.0.0.1";
          kvstore.store = "inmemory";
        };
        replication_factor = 1;
        path_prefix = "/var/lib/loki";
      };
      schema_config = {
        configs = [
          {
            from = "2020-05-15";
            store = "tsdb";
            object_store = "s3";
            schema = "v13";
            index = {
              prefix = "index_";
              period = "24h";
            };
          }
        ];
      };
      storage_config = {
        tsdb_shipper = {
          active_index_directory = "/var/lib/loki/index";
          cache_location = "/var/lib/loki/cache";
        };
        aws = {
          access_key_id = "\${ACCESS_KEY}";
          secret_access_key = "\${SECRET_KEY}";
          endpoint = "127.0.0.1:3900";
          s3forcepathstyle = true;
          region = "garage";
          insecure = true;
          s3 = "s3://\${ACCESS_KEY}:\${SECRET_KEY}@127.0.0.1:3900/loki";
        };
      };
    };
  };
  system.activationScripts.makeLokiDir = lib.stringAfter [ "var" ] ''
    mkdir -p /var/lib/loki/{index,cache}
    chown ${config.services.loki.user}:${config.services.loki.group} -R /var/lib/loki
  '';
}
