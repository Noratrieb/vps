{
  meta =
    let nixpkgs-path = (fetchTarball "https://github.com/NixOS/nixpkgs/archive/7105ae3957700a9646cc4b766f5815b23ed0c682.tar.gz"); in
    {
      # Override to pin the Nixpkgs version (recommended). This option
      # accepts one of the following:
      # - A path to a Nixpkgs checkout
      # - The Nixpkgs lambda (e.g., import <nixpkgs>)
      # - An initialized Nixpkgs attribute set
      nixpkgs = import nixpkgs-path; # nixos-24.11 2025-03-21

      specialArgs = {
        website = import (fetchTarball "https://github.com/Noratrieb/website/archive/57c4a239da5d17eafde4ade165f3c6706639a9b4.tar.gz");
        blog = fetchTarball "https://github.com/Noratrieb/blog/archive/04f7cf7d27db359cbf9fac2e9e3e677a7e76abd9.tar.gz";
        slides = fetchTarball "https://github.com/Noratrieb/slides/archive/0401f35c22b124b69447655f0c537badae9e223c.tar.gz";

        pretense = import (fetchTarball "https://github.com/Noratrieb/pretense/archive/270b01fc1118dfd713c1c41530d1a7d98f04527d.tar.gz");
        quotdd = import (fetchTarball "https://github.com/Noratrieb/quotdd/archive/9c37b3e2093020771ee7c9da6200f95d4269b4e4.tar.gz");

        does-it-build = import (fetchTarball "https://github.com/Noratrieb/does-it-build/archive/7f4c69e51f38328f7408e06fb2046b991d429d87.tar.gz");

        inherit nixpkgs-path;

        networkingConfig = {
          dns1 = {
            publicIPv4 = "154.38.163.74";
            publicIPv6 = null;
            wg = {
              privateIP = "10.0.1.1";
              publicKey = "7jy2q93xYBHG5yKqLmNuMWSuFMnUGWXVuKQ1yMmxoV4=";
              peers = [ "vps3" ];
            };
          };
          dns2 = {
            publicIPv4 = "128.140.3.7";
            # somehow this doesnt quite work yet, keep it out of DNS records
            #publicIPv6 = "2a01:4f8:c2c:d616::";
            publicIPv6 = null;
            wg = {
              privateIP = "10.0.1.2";
              publicKey = "yfOc/q5M+2DWPoZ4ZgwrTYYkviQxGxRWpcBCDcauDnc=";
              peers = [ "vps3" ];
            };
          };
          vps1 = {
            publicIPv4 = "161.97.165.1";
            publicIPv6 = null;
            wg = {
              privateIP = "10.0.0.1";
              publicKey = "5tg3w/TiCuCeKIBJCd6lHUeNjGEA76abT1OXnhNVyFQ=";
              peers = [ "vps3" "vps4" "vps5" ];
            };
          };
          vps3 = {
            publicIPv4 = "134.255.181.139";
            publicIPv6 = null;
            wg = {
              privateIP = "10.0.0.3";
              publicKey = "pdUxG1vhmYraKzIIEFxTRAMhGwGztBL/Ly5icJUV3g0=";
              peers = [ "vps1" "vps4" "vps5" "dns1" "dns2" ];
            };
          };
          vps4 = {
            publicIPv4 = "195.201.147.17";
            # somehow this doesnt quite work yet, keep it out of DNS records
            #publicIPv6 = "2a01:4f8:1c1c:cb18::1";
            publicIPv6 = null;
            wg = {
              privateIP = "10.0.0.4";
              publicKey = "+n2XKKaSFdCanEGRd41cvnuwJ0URY0HsnpBl6ZrSBRs=";
              peers = [ "vps1" "vps3" "vps5" ];
            };
          };
          vps5 = {
            publicIPv4 = "45.94.209.30";
            publicIPv6 = null;
            wg = {
              privateIP = "10.0.0.5";
              publicKey = "r1cwt63fcOR+FTqMTUpZdK4/MxpalkDYRHXyy7osWUk=";
              peers = [ "vps1" "vps3" "vps4" ];
            };
          };
        };
      };

      # If your Colmena host has nix configured to allow for remote builds
      # (for nix-daemon, your user being included in trusted-users)
      # you can set a machines file that will be passed to the underlying
      # nix-store command during derivation realization as a builders option.
      # For example, if you support multiple orginizations each with their own
      # build machine(s) you can ensure that builds only take place on your
      # local machine and/or the machines specified in this file.
      # machinesFile = ./machines.client-a;
    };

  defaults = { pkgs, config, lib, ... }: {
    # This module will be imported by all hosts
    imports = [ ./modules/default ];
  };

  dns1 = { name, nodes, modulesPath, ... }: {
    imports = [
      (modulesPath + "/profiles/qemu-guest.nix")
      ./modules/contabo
      ./modules/dns
      ./modules/wg-mesh
    ];

    # The name and nodes parameters are supported in Colmena,
    # allowing you to reference configurations in other nodes.
    deployment.tags = [ "dns" "us" ];
    system.stateVersion = "23.11";
  };
  dns2 = { name, nodes, modulesPath, lib, ... }: {
    imports = [
      (modulesPath + "/profiles/qemu-guest.nix")
      ./modules/dns
      ./modules/wg-mesh
    ];

    deployment.tags = [ "dns" "eu" "hetzner" ];
    system.stateVersion = "23.11";

    boot.loader.grub.device = "/dev/sda";
    boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi" ];
    boot.initrd.kernelModules = [ "nvme" ];
    fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };

    # This file was populated at runtime with the networking
    # details gathered from the active system.
    networking = {
      nameservers = [
        "8.8.8.8"
      ];
      defaultGateway = "172.31.1.1";
      defaultGateway6 = {
        address = "fe80::1";
        interface = "eth0";
      };
      dhcpcd.enable = false;
      usePredictableInterfaceNames = lib.mkForce false;
      interfaces = {
        eth0 = {
          ipv4.addresses = [
            { address = "128.140.3.7"; prefixLength = 32; }
          ];
          ipv6.addresses = [
            { address = "2a01:4f8:c2c:d616::1"; prefixLength = 64; }
            { address = "fe80::9400:3ff:fe91:1647"; prefixLength = 64; }
          ];
          ipv4.routes = [{ address = "172.31.1.1"; prefixLength = 32; }];
          ipv6.routes = [{ address = "fe80::1"; prefixLength = 128; }];
        };

      };
    };
    services.udev.extraRules = ''
      ATTR{address}=="96:00:03:91:16:47", NAME="eth0"
    '';
  };

  # VPS1 is the primary app server.
  vps1 = { name, nodes, modulesPath, config, lib, ... }: {
    imports = [
      (modulesPath + "/profiles/qemu-guest.nix")
      ./modules/contabo
      ./modules/wg-mesh
      ./modules/caddy
      ./modules/garage
      ./modules/podman
      ./modules/registry
      ./modules/backup

      # apps
      ./apps/widetom
      ./apps/hugo-chat
      ./apps/uptime
      ./apps/cargo-bisect-rustc-service
      ./apps/killua
      ./apps/forgejo
      ./apps/openolat
    ];

    deployment.tags = [ "caddy" "eu" "apps" "website" ];
    system.stateVersion = "23.11";
  };
  # VPS3 is the primary monitoring/metrics server.
  vps3 = { name, nodes, modulesPath, config, ... }: {
    imports = [
      (modulesPath + "/profiles/qemu-guest.nix")
      ./modules/contabo
      ./modules/wg-mesh
      ./modules/caddy
      ./modules/garage
      ./modules/prometheus
    ];

    deployment.tags = [ "eu" "apps" "website" ];
    system.stateVersion = "23.11";
  };
  # VPS4 exists. It's useful for garage replication and runs does-it-build which uses some CPU.
  vps4 = { lib, modulesPath, ... }: {
    imports = [
      (modulesPath + "/profiles/qemu-guest.nix")
      ./modules/caddy
      ./modules/wg-mesh
      ./modules/garage
      ./modules/backup

      # apps
      ./apps/does-it-build
    ];

    deployment.tags = [ "eu" "apps" "hetzner" "website" ];
    system.stateVersion = "23.11";

    boot.loader.grub.device = "/dev/sda";
    boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi" ];
    boot.initrd.kernelModules = [ "nvme" ];
    fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };

    # This file was populated at runtime with the networking
    # details gathered from the active system.
    networking = {
      nameservers = [
        "8.8.8.8"
      ];
      defaultGateway = "172.31.1.1";
      defaultGateway6 = {
        address = "fe80::1";
        interface = "eth0";
      };
      dhcpcd.enable = false;
      usePredictableInterfaceNames = lib.mkForce false;
      interfaces = {
        eth0 = {
          ipv4.addresses = [
            { address = "195.201.147.17"; prefixLength = 32; }
          ];
          ipv6.addresses = [
            { address = "2a01:4f8:1c1c:cb18::1"; prefixLength = 64; }
            { address = "fe80::9400:3ff:fe95:a9e4"; prefixLength = 64; }
          ];
          ipv4.routes = [{ address = "172.31.1.1"; prefixLength = 32; }];
          ipv6.routes = [{ address = "fe80::1"; prefixLength = 128; }];
        };

      };
    };
    services.udev.extraRules = ''
      ATTR{address}=="96:00:03:95:a9:e4", NAME="eth0"
    
    '';
  };
  # VPS5 is the primary test server, where new things are being deployed that could break stuff maybe.
  vps5 = { name, nodes, modulesPath, config, pkgs, lib, ... }:
    let
      commit = "5f203d0f5ba2639043bd5bd1c3687c406d6abac1";
      cluelessh = import (fetchTarball "https://github.com/Noratrieb/cluelessh/archive/${commit}.tar.gz");
    in
    {
      imports = [
        (modulesPath + "/profiles/qemu-guest.nix")
        ./modules/contabo
        ./modules/caddy
        ./modules/wg-mesh
        ./modules/garage
      ];


      services.openssh.ports = [ 2000 ];
      systemd.services.fakessh = {
        description = "cluelessh-faked ssh honeypot";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        serviceConfig = {
          Restart = "on-failure";
          RestartSec = "5s";
          ExecStart = "${lib.getExe' (cluelessh {inherit pkgs;}) "cluelessh-faked" }";

          # i really don't trust this.
          DynamicUser = true;
          AmbientCapabilities = "CAP_NET_BIND_SERVICE";
          MemoryHigh = "100M";
          MemoryMax = "200M";

          # config
          Environment = [
            "FAKESSH_LISTEN_ADDR=0.0.0.0:22"
            "RUST_LOG=debug"
            #"FAKESSH_JSON_LOGS=1"
          ];
        };
      };
      networking.firewall.allowedTCPPorts = [ 22 ];

      deployment.targetPort = 2000;
      deployment.tags = [ "eu" "apps" ];
      system.stateVersion = "23.11";
    };
}
