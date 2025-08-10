{
  meta =
    let
      nixpkgs-version = builtins.fromJSON (builtins.readFile ./nixpkgs.json);
      nixpkgs-path = (fetchTarball "https://github.com/NixOS/nixpkgs/archive/${nixpkgs-version.commit}.tar.gz");
    in
    {
      # Override to pin the Nixpkgs version (recommended). This option
      # accepts one of the following:
      # - A path to a Nixpkgs checkout
      # - The Nixpkgs lambda (e.g., import <nixpkgs>)
      # - An initialized Nixpkgs attribute set
      nixpkgs = import nixpkgs-path;

      specialArgs = {
        my-projects-versions = builtins.fromJSON (builtins.readFile ./my-projects.json);

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
            tags = [ "dns" ];
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
            tags = [ "dns" ];
          };
          vps1 = {
            publicIPv4 = "161.97.165.1";
            publicIPv6 = null;
            wg = {
              privateIP = "10.0.0.1";
              publicKey = "5tg3w/TiCuCeKIBJCd6lHUeNjGEA76abT1OXnhNVyFQ=";
              peers = [ "vps2" "vps3" "vps4" "vps5" ];
            };
            tags = [ "apps" ];
          };
          vps2 = {
            publicIPv4 = "184.174.32.252";
            publicIPv6 = null;
            wg = {
              privateIP = "10.0.0.2";
              publicKey = "SficHHJ0ynpZoGah5heBpNKnEVIVrgs72Z5HEKd3jHA=";
              peers = [ "vps1" "vps3" "vps4" "vps5" ];
            };
            tags = [ "apps" ];
          };
          vps3 = {
            publicIPv4 = "134.255.181.139";
            publicIPv6 = null;
            wg = {
              privateIP = "10.0.0.3";
              publicKey = "pdUxG1vhmYraKzIIEFxTRAMhGwGztBL/Ly5icJUV3g0=";
              peers = [ "vps1" "vps2" "vps4" "vps5" "dns1" "dns2" ];
            };
            tags = [ "apps" ];
          };
          vps4 = {
            publicIPv4 = "195.201.147.17";
            # somehow this doesnt quite work yet, keep it out of DNS records
            #publicIPv6 = "2a01:4f8:1c1c:cb18::1";
            publicIPv6 = null;
            wg = {
              privateIP = "10.0.0.4";
              publicKey = "+n2XKKaSFdCanEGRd41cvnuwJ0URY0HsnpBl6ZrSBRs=";
              peers = [ "vps1" "vps2" "vps3" "vps5" ];
            };
            tags = [ "apps" ];
          };
          vps5 = {
            publicIPv4 = "45.94.209.30";
            publicIPv6 = null;
            wg = {
              privateIP = "10.0.0.5";
              publicKey = "r1cwt63fcOR+FTqMTUpZdK4/MxpalkDYRHXyy7osWUk=";
              peers = [ "vps1" "vps2" "vps3" "vps4" ];
            };
            tags = [ "apps" ];
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

    system.stateVersion = "23.11";
  };
  dns2 = { name, nodes, modulesPath, lib, ... }: {
    imports = [
      (modulesPath + "/profiles/qemu-guest.nix")
      ./modules/dns
      ./modules/wg-mesh
    ];

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
      ./apps/website
      ./apps/old-redirects
      ./apps/widetom
      ./apps/hugo-chat
      ./apps/killua
      ./apps/forgejo
      ./apps/openolat
      ./apps/upload-files
    ];

    system.stateVersion = "23.11";
  };
  # VPS2 exists
  vps2 = { name, nodes, modulesPath, config, lib, ... }: {
    imports = [
      (modulesPath + "/profiles/qemu-guest.nix")
      ./modules/contabo
      ./modules/wg-mesh
      ./modules/caddy
      ./modules/garage
    ];

    networking.useDHCP = false;
    systemd.network.enable = true;
    systemd.network.networks."10-ens18" = {
      matchConfig.MacAddress = "00:50:56:49:f0:60";
      networkConfig = {
        LinkLocalAddressing = "ipv6";
        Address = [ "184.174.32.252/21" "2a02:c206:2119:3519:0000:0000:0000:0001/64" ];
        Gateway = "fe80::1";
        DNS = [ "213.136.95.11" "213.136.95.10" "2a02:c207::2:53" "2a02:c207::1:53" "invalid" ];
        Domains = "invalid";
      };
      routes = [
        {
          Destination = "0.0.0.0/0";
          Gateway = "184.174.32.1";
          GatewayOnLink = true;
        }
      ];
    };

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

      ./apps/website
    ];

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
      ./apps/website
      ./apps/does-it-build
    ];

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
    {
      imports = [
        (modulesPath + "/profiles/qemu-guest.nix")
        ./modules/contabo
        ./modules/caddy
        ./modules/wg-mesh
        ./modules/garage
        ./apps/fakessh
      ];

      services.openssh.ports = [ 2000 ];
      deployment.targetPort = 2000;

      system.stateVersion = "23.11";
    };
}
