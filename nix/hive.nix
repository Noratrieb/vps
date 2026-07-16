{
  meta =
    let
      nixpkgs-version = builtins.fromJSON (builtins.readFile ./nixpkgs.json);
      nixpkgs-path = (fetchTarball "https://github.com/NixOS/nixpkgs/archive/${nixpkgs-version."nixos-26.05".commit}.tar.gz");
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
              peers = [ "minipc" "vps3" "vps5" ];
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
              peers = [ "vps1" "vps2" "vps4" "vps5" "dns1" "dns2" "minipc" ];
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
              peers = [ "dns1" "vps1" "vps2" "vps3" "vps4" ];
            };
            tags = [ "apps" ];
          };
          minipc = {
            publicIPv4 = null;
            publicIPv6 = null;
            wg = {
              privateIP = "10.0.2.1";
              publicKey = "ecYfTot7RrJyNebSZTQ1wciOhvrpNSSbkR15twpSSl4=";
              peers = [ "dns1" "vps3" ];
              noEndpoint = true;
            };
            tags = [ "home" ];
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
      ./modules/disko/base
      ./modules/disko/standard
      ./modules/dns
      ./modules/wg-mesh
    ];

    system.stateVersion = "23.11";
  };
  dns2 = { name, nodes, modulesPath, lib, ... }: {
    imports = [
      (modulesPath + "/profiles/qemu-guest.nix")
      ./modules/disko/base
      ./modules/disko/standard
      ./modules/dns
      ./modules/wg-mesh
    ];

    system.stateVersion = "23.11";

    boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];
    boot.initrd.kernelModules = [ "dm-snapshot" ];
    boot.kernelModules = [ ];
    boot.extraModulePackages = [ ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
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
      ./modules/restic
      ./modules/snowflake-proxy

      # apps
      ./apps/website
      ./apps/old-redirects
      ./apps/widetom
      ./apps/hugo-chat
      ./apps/killua
      ./apps/forgejo
      ./apps/openolat
      ./apps/upload-files
      ./modules/hedgedoc
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
      ./modules/snowflake-proxy

      # apps
      ./apps/matrix
    ];

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
      ./modules/snowflake-proxy

      ./apps/website
    ];

    system.stateVersion = "23.11";
  };
  # VPS4 exists. It's useful for garage replication and runs does-it-build which uses some CPU.
  vps4 = { lib, modulesPath, ... }: {
    imports = [
      (modulesPath + "/profiles/qemu-guest.nix")
      ./modules/disko/base
      ./modules/disko/standard
      ./modules/caddy
      ./modules/wg-mesh
      ./modules/garage
      ./modules/backup
      ./modules/restic
      ./modules/snowflake-proxy

      # apps
      ./apps/website
      ./apps/does-it-build
    ];

    system.stateVersion = "23.11";

    boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];
    boot.initrd.kernelModules = [ "dm-snapshot" ];
    boot.kernelModules = [ ];
    boot.extraModulePackages = [ ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
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
        ./modules/snowflake-proxy
        ./apps/fakessh
      ];

      services.openssh.ports = [ 2000 ];
      deployment.targetPort = 2000;

      system.stateVersion = "23.11";
    };
  minipc = { name, nodes, modulesPath, config, pkgs, lib, ... }: {
    imports = [
      ./modules/minipc
      ./modules/wg-mesh
      ./modules/nas-mount
      ./modules/postgres
      ./modules/immich
      ./modules/tailscale
      ./modules/paperless
      ./modules/home-assistant
      ./modules/caddy-base
      ./modules/caddy-acme-dns
    ];

    system.stateVersion = "25.05";
  };
}
