{
  meta = {
    # Override to pin the Nixpkgs version (recommended). This option
    # accepts one of the following:
    # - A path to a Nixpkgs checkout
    # - The Nixpkgs lambda (e.g., import <nixpkgs>)
    # - An initialized Nixpkgs attribute set
    nixpkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/a1cc729dcbc31d9b0d11d86dc7436163548a9665.tar.gz"); # nixos-24.05 2024-07-26

    specialArgs = {
      nixpkgs-unstable = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/d04953086551086b44b6f3c6b7eeb26294f207da.tar.gz") { }; # nixos-unstable 2024-08-05

      website = import (fetchTarball "https://github.com/Noratrieb/website/archive/dc4352b9f01c4780539bdd50249d8f552e541fd9.tar.gz");
      blog = fetchTarball "https://github.com/Noratrieb/nilstrieb.github.io/archive/8162ce0cff29f940507032be6b0692290d73594c.tar.gz";
      slides = fetchTarball "https://github.com/Noratrieb/slides/archive/0401f35c22b124b69447655f0c537badae9e223c.tar.gz";

      networkingConfig = {
        dns1 = {
          publicIPv4 = "154.38.163.74";
          publicIPv6 = null;
        };
        dns2 = {
          publicIPv4 = "128.140.3.7";
          # somehow this doesnt quite work yet, keep it out of DNS records
          #publicIPv6 = "2a01:4f8:c2c:d616::";
          publicIPv6 = null;
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
            peers = [ "vps1" "vps4" "vps5" ];
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

  vps1 = { name, nodes, modulesPath, config, lib, ... }: {
    imports = [
      (modulesPath + "/profiles/qemu-guest.nix")
      ./modules/contabo
      ./modules/wg-mesh
      ./modules/ingress
      ./modules/garage
      ./modules/podman

      # apps
      ./apps/widetom
      ./apps/hugo-chat
      ./apps/uptime
      ./apps/cargo-bisect-rustc-service
      ./apps/registry
    ];

    deployment.tags = [ "ingress" "eu" "apps" "wg" ];
    system.stateVersion = "23.11";
  };
  vps3 = { name, nodes, modulesPath, config, ... }: {
    imports = [
      (modulesPath + "/profiles/qemu-guest.nix")
      ./modules/contabo
      ./modules/wg-mesh
      ./modules/ingress
      ./modules/garage
      ./modules/prometheus
    ];

    deployment.tags = [ "eu" "apps" "wg" ];
    system.stateVersion = "23.11";
  };
  vps4 = { lib, modulesPath, ... }: {
    imports = [
      (modulesPath + "/profiles/qemu-guest.nix")
      ./modules/ingress
      ./modules/wg-mesh
      ./modules/garage
    ];

    deployment.tags = [ "eu" "apps" "hetzner" ];
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
  vps5 = { name, nodes, modulesPath, config, ... }: {
    imports = [
      (modulesPath + "/profiles/qemu-guest.nix")
      ./modules/contabo
      ./modules/ingress
      ./modules/wg-mesh
      ./modules/garage
    ];

    deployment.tags = [ "eu" "apps" "wg" ];
    system.stateVersion = "23.11";
  };
}
