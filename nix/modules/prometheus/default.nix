{ config, lib, networkingConfig, pkgs, ... }: {
  services.prometheus = {
    enable = true;
    globalConfig = { };
    scrapeConfigs =
      let hostsWithTag = tag: map (entry: entry.name) (builtins.filter (entry: builtins.elem tag entry.value.tags) (lib.attrsToList networkingConfig)); in
      [
        {
          job_name = "prometheus";
          static_configs = [
            { targets = [ "localhost:9090" ]; labels = { server = "vps3"; }; }
          ];
        }
        {
          job_name = "node";
          static_configs = map
            (name: {
              targets = [ "${name}.local:9100" ];
              labels = { server = name; };
            })
            (builtins.attrNames networkingConfig);
        }
        {
          job_name = "cadvisor";
          static_configs = map
            (name: {
              targets = [ "${name}.local:8080" ];
              labels = { server = name; };
            })
            (builtins.attrNames networkingConfig);
        }
        {
          job_name = "systemd";
          static_configs = map
            (name: {
              targets = [ "${name}.local:9558" ];
              labels = { server = name; };
            })
            (builtins.attrNames networkingConfig);
        }
        {
          job_name = "caddy";
          static_configs = map
            (name: {
              targets = [ "${name}.local:9010" ];
              labels = { server = name; };
            })
            (hostsWithTag "apps");
        }
        {
          job_name = "docker-registry";
          static_configs = [
            { targets = [ "vps1.local:9011" ]; labels = { server = "vps1"; }; }
          ];
        }
        {
          job_name = "garage";
          static_configs = map
            (name: {
              targets = [ "${name}.local:3903" ];
              labels = { server = name; };
            })
            (hostsWithTag "apps");
        }
        {
          job_name = "knot";
          static_configs = map
            (name: {
              targets = [ "${name}.local:9433" ];
              labels = { server = name; };
            })
            (hostsWithTag "dns");
        }
        {
          job_name = "pretense";
          static_configs = map
            (name: {
              targets = [ "${name}.local:9150" ];
              labels = { server = name; };
            })
            (builtins.attrNames networkingConfig);
        }
        {
          job_name = "std-internal-docs-status";
          scrape_interval = "1h";
          static_configs = [{ targets = [ "localhost:7846" ]; }];
        }
      ];
  };

  systemd.services.prometheus-exporter-std-internal-docs-status = {
    description = "Cursed hack to get the GitHub deployment status of std.noratrieb.dev";
    serviceConfig = {
      DynamicUser = true;
      ExecStart = "${lib.getExe pkgs.nodejs_24} ${./prometheus-exporter-std-internal-docs.mjs}";
    };
    wantedBy = [ "multi-user.target" ];
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
            url = "http://prometheus.internal:9090";
            jsonData = {
              httpMethod = "POST";
              prometheusType = "Prometheus";
            };
          }
          {
            name = "loki";
            type = "loki";
            access = "proxy";
            url = "http://loki.internal:3100";
          }
          {
            name = "pyroscope";
            type = "grafana-pyroscope-datasource";
            access = "proxy";
            url = "http://pyroscope.internal:4040";
          }
        ];
      };
    };
  };

  services.caddy.virtualHosts."grafana.noratrieb.dev" = {
    logFormat = "";
    extraConfig = ''
      encode zstd gzip
      reverse_proxy * localhost:3000
    '';
  };

  networking.firewall.interfaces.wg0.allowedTCPPorts = [
    config.services.loki.configuration.server.http_listen_port
    4040 # pyroscope
  ];
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


  age.secrets.pyroscope_s3_secret = {
    file = ../../secrets/pyroscope_s3_secret.age;
    owner = config.users.users.pyroscope.name;
  };

  systemd.services.pyroscope =
    let
      pyroscope = pkgs.fetchzip {
        url = "https://github.com/grafana/pyroscope/releases/download/v1.14.0/pyroscope_1.14.0_linux_amd64.tar.gz";
        sha256 = "sha256:005539bp2a2kac8ff6vz77g0niav81rggha1bsfx454fw4dyli4y";
        stripRoot = false;
      };
      pyroscopeConfig = {
        analytics.reporting_enabled = false;
        server = {
          grpc_listen_port = 9084; # random port
        };
        storage = {
          backend = "s3";
          s3 = {
            bucket_name = "pyroscope";
            region = "garage";
            endpoint = "localhost:3900";
            insecure = true;
            access_key_id = "\${ACCESS_KEY_ID}";
            secret_access_key = "\${ACCESS_SECRET_KEY}";
          };
        };
      };
    in
    {
      description = "pyroscope, the continuous profiling database";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Restart = "always";
        User = config.users.users.pyroscope.name;
        Group = config.users.users.pyroscope.group;
        ExecStart = "${pyroscope}/pyroscope -config.expand-env=true -config.file ${pkgs.writeText "config.yml" (builtins.toJSON pyroscopeConfig)}";
        EnvironmentFile = config.age.secrets.pyroscope_s3_secret.path;
        WorkingDirectory = "/var/lib/pyroscope";
      };
    };

  users.users.pyroscope = {
    group = "pyroscope";
    isSystemUser = true;
    home = "/var/lib/pyroscope";
    createHome = true;
  };
  users.groups.pyroscope = { };
}
