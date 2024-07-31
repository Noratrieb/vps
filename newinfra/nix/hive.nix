{
  meta = {
    # Override to pin the Nixpkgs version (recommended). This option
    # accepts one of the following:
    # - A path to a Nixpkgs checkout
    # - The Nixpkgs lambda (e.g., import <nixpkgs>)
    # - An initialized Nixpkgs attribute set
    nixpkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/a1cc729dcbc31d9b0d11d86dc7436163548a9665.tar.gz"); # nixos-24.05 2024-07-26

    specialArgs = {
      networkingConfig = {
        dns1 = {
          publicIPv4 = "154.38.163.74";
          publicIPv6 = null;
        };
        dns2 = {
          publicIPv4 = "128.140.3.7";
          publicIPv6 = "2a01:4f8:c2c:d616::";

        };
        vps1 = {
          publicIPv4 = "161.97.165.1";
          publicIPv6 = null;

        };
        vps3 = {
          publicIPv4 = "134.255.181.139";
          publicIPv6 = null;
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

    deployment.tags = [ "dns" "eu" ];
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

  vps1 = { name, nodes, modulesPath, config, ... }: {
    imports = [
      (modulesPath + "/profiles/qemu-guest.nix")
      ./modules/contabo
      ./modules/wg-mesh
      ./modules/ingress
      ./modules/widetom
    ];

    age.secrets.docker_registry_password.file = ./secrets/docker_registry_password.age;

    deployment.tags = [ "ingress" "eu" "apps" "wg" ];
    system.stateVersion = "23.11";

    # TODO: move
    age.secrets.wg_private.file = ./secrets/wg_private_vps1.age;
    networking.wg-quick.interfaces = {
      wg0 = {
        address = [ "10.0.0.1/24" ];
        listenPort = 51820;

        privateKeyFile = config.age.secrets.wg_private.path;

        peers = [
          {
            publicKey = "pdUxG1vhmYraKzIIEFxTRAMhGwGztBL/Ly5icJUV3g0=";
            endpoint = "vps3.infra.noratrieb.dev:51820";
            allowedIPs = [ "10.0.0.3/32" ];
            # TODO: Use PSK
          }
        ];
      };
    };
  };
  vps3 = { name, nodes, modulesPath, config, ... }: {
    imports = [
      (modulesPath + "/profiles/qemu-guest.nix")
      ./modules/contabo
      ./modules/wg-mesh
    ];

    deployment.tags = [ "eu" "apps" "wg" ];
    system.stateVersion = "23.11";

    # TODO: move
    age.secrets.wg_private.file = ./secrets/wg_private_vps3.age;
    networking.wg-quick.interfaces = {
      wg0 = {
        address = [ "10.0.0.3/24" ];
        listenPort = 51820;

        privateKeyFile = config.age.secrets.wg_private.path;

        peers = [
          {
            publicKey = "5tg3w/TiCuCeKIBJCd6lHUeNjGEA76abT1OXnhNVyFQ=";
            endpoint = "vps1.infra.noratrieb.dev:51820";
            allowedIPs = [ "10.0.0.1/32" ];
            # TODO: Use PSK
          }
        ];
      };
    };
  };
}
