{
  meta = {
    # Override to pin the Nixpkgs version (recommended). This option
    # accepts one of the following:
    # - A path to a Nixpkgs checkout
    # - The Nixpkgs lambda (e.g., import <nixpkgs>)
    # - An initialized Nixpkgs attribute set
    nixpkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/a1cc729dcbc31d9b0d11d86dc7436163548a9665.tar.gz"); # nixos-24.05 2024-07-26

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
    environment.systemPackages = with pkgs; [
      vim
      wget
      curl
      traceroute
      dnsutils
    ];

    imports = [
      "${builtins.fetchTarball "https://github.com/ryantm/agenix/archive/de96bd907d5fbc3b14fc33ad37d1b9a3cb15edc6.tar.gz"}/modules/age.nix" # main 2024-07-26
    ];

    deployment.targetHost = "${config.networking.hostName}.infra.noratrieb.dev";
    time.timeZone = "Europe/Zurich";
    users.users.root.openssh.authorizedKeys.keys = [ ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG0n1ikUG9rYqobh7WpAyXrqZqxQoQ2zNJrFPj12gTpP nilsh@PC-Nils'' ];

    boot.tmp.cleanOnBoot = true;
    zramSwap.enable = true;

    services.openssh = {
      enable = true;
      banner = "meoooooow!! 😼 :3\n";
      settings = {
        PasswordAuthentication = false;
      };
    };
    services.fail2ban = {
      enable = true;
    };
    system.nixos.distroName = "NixOS (gay 🏳️‍⚧️)";
  };

  dns1 = { name, nodes, modulesPath, ... }: {
    imports = [
      (modulesPath + "/profiles/qemu-guest.nix")
      ./modules/contabo
      ./modules/dns
    ];

    # The name and nodes parameters are supported in Colmena,
    # allowing you to reference configurations in other nodes.
    networking.hostName = name;
    deployment.tags = [ "dns" "us" ];
    system.stateVersion = "23.11";
  };
  dns2 = { name, nodes, modulesPath, lib, ... }: {
    imports = [
      (modulesPath + "/profiles/qemu-guest.nix")
      ./modules/dns
    ];

    networking.hostName = name;
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

  vps1 = { name, nodes, modulesPath, ... }: {
    imports = [
      (modulesPath + "/profiles/qemu-guest.nix")
      ./modules/contabo
      ./modules/ingress
      ./modules/minio
      ./modules/widetom
    ];

    age.secrets.docker_registry_password.file = ./secrets/docker_registry_password.age;

    networking.hostName = name;
    deployment.tags = [ "ingress" "eu" "apps" ];
    system.stateVersion = "23.11";
  };
}
