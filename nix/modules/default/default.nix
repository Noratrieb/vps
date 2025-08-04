{ pkgs, lib, name, my-projects-versions, networkingConfig, nixpkgs-path, ... }:
let
  pretense = import (fetchTarball "https://github.com/Noratrieb/pretense/archive/${my-projects-versions.pretense}.tar.gz");
  quotdd = import (fetchTarball "https://github.com/Noratrieb/quotdd/archive/${my-projects-versions.quotdd}.tar.gz");
in
{
  deployment.targetHost = "${name}.infra.noratrieb.dev";

  networking.hosts = {
    "${networkingConfig.vps3.wg.privateIP}" = [ "loki.internal" "pyroscope.internal" "prometheus.internal" ];
  };

  imports = [
    "${builtins.fetchTarball "https://github.com/ryantm/agenix/archive/de96bd907d5fbc3b14fc33ad37d1b9a3cb15edc6.tar.gz"}/modules/age.nix" # main 2024-07-26
  ];

  nix = {
    nixPath = [ "nixpkgs=${nixpkgs-path}" ];
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    traceroute
    dnsutils
    nftables
  ];

  networking.hostName = name;

  time.timeZone = "Europe/Zurich";
  users.users.root.openssh.authorizedKeys.keys = [ ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG0n1ikUG9rYqobh7WpAyXrqZqxQoQ2zNJrFPj12gTpP nilsh@PC-Nils'' ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;

  services.openssh = {
    enable = true;
    openFirewall = true;
    banner = "meoooooow!! 😼 :3\n";
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        # P256
        path = "/etc/ssh/ssh_host_ecdsa_key";
        type = "ecdsa";
      }
      {
        bits = 4096;
        path = "/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
      }
    ];

    settings = {
      PasswordAuthentication = false;
    };
  };
  services.fail2ban = {
    enable = true;
  };
  system.nixos.distroName = "NixOS (gay 🏳️‍⚧️)";

  systemd.services.pretense = {
    description = "pretense connection logger";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      DynamicUser = true;
      ExecStart = "${lib.getExe (pretense {inherit pkgs;})}";
      AmbientCapabilities = "CAP_NET_BIND_SERVICE";
      Environment = [
        "PRETENSE_PORTS=23,3306,5432,1521" # telnet,mysql,postgres,oracle
        "PRETENSE_METRICS_PORT=9150"
      ];
    };
  };
  systemd.services.quotdd = {
    description = "quotdd Quote of The Day Daemon";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      DynamicUser = true;
      ExecStart = "${lib.getExe (quotdd {inherit pkgs;})}";
      AmbientCapabilities = "CAP_NET_BIND_SERVICE";
      Environment = [ ];
    };
  };
  networking.firewall.allowedTCPPorts = [
    23 # telnet, pretense
    3306 # mysql, pretense
    5432 # postgres, pretense
    1521 # oracle, pretense
    17 # quote of the day, quotdd
  ];

  # monitoring

  networking.firewall.interfaces.wg0.allowedTCPPorts = [
    8080 # cadvisor exporter
    9100 # node exporter
    9150 # pretense exporter
    9558 # systemd exporter
  ];
  services.prometheus.exporters = {
    node = {
      enable = true;
    };
    systemd = {
      enable = true;
    };
  };
  services.cadvisor = {
    enable = true;
    listenAddress = "0.0.0.0";
    extraOptions = [
      # significantly decreases CPU usage (https://github.com/google/cadvisor/issues/2523)
      "--housekeeping_interval=30s"
    ];
  };
  services.promtail = {
    enable = true;
    configuration = {
      server = {
        disable = true;
      };
      clients = [
        {
          url = "http://loki.internal:3100/loki/api/v1/push";
        }
      ];
      scrape_configs = [
        {
          job_name = "journal";
          journal = {
            max_age = "24h";
            labels = {
              job = "systemd-journal";
              node = name;
            };
          };
          pipeline_stages = [{
            match = {
              selector = "{unit = \"sshd.service\"} |= \"Invalid user\"";
              stages = [
                { regex = { expression = "Invalid user.*from (?P<ip>.*) port.*"; }; }
                {
                  geoip = {
                    db = pkgs.fetchurl
                      {
                        # Note: You cannot use this for your own usage, this is only for me.
                        url = "https://github.com/noratrieb-mirrors/maxmind-geoip/releases/download/20240922/GeoLite2-City.mmdb";
                        sha256 = "sha256-xRGf2JEaEHpxEkIq3jJnZv49lTisFbygbjxiIZHIThg=";
                      };
                    source = "ip";
                    db_type = "city";
                  };
                }
              ];
            };
          }];
          relabel_configs = [
            {
              source_labels = [ "__journal__systemd_unit" ];
              target_label = "unit";
            }
            {
              source_labels = [ "__journal__hostname" ];
              target_label = "host";
            }
            {
              source_labels = [ "__journal_priority_keyword" ];
              target_label = "severity";
              regex = "(.+)";
            }
          ];
        }
      ];
    };
  };

  services.alloy = {
    enable = true;
  };
  systemd.services.alloy.serviceConfig = {
    DynamicUser = lib.mkForce false;
  };
  environment.etc."alloy/config.alloy".text = ''
    discovery.process "all" {
      discover_config {
        cgroup_path = true
        container_id = true
      }
    }

    discovery.relabel "alloy" {
      targets = discovery.process.all.targets
      // Filter needed processes
      rule {
          source_labels = ["__meta_process_cgroup_path"]
          regex = "0::/system.slice/.*.service"
          action = "keep"
      }

      rule {
        source_labels = ["__meta_process_cgroup_path"]
        regex = "0::/system.slice/(.*.service)"
        target_label = "service_name"
        action = "replace"
      }
    }

    pyroscope.ebpf "instance" {
      forward_to     = [pyroscope.write.endpoint.receiver]
      targets = discovery.relabel.alloy.output
    }

    pyroscope.write "endpoint" {
      endpoint {
        url = "http://pyroscope.internal:4040"
      }
      external_labels = {
        "instance" = env("HOSTNAME"),
      }
    }
  '';

  deployment.tags = networkingConfig."${name}".tags;
}
