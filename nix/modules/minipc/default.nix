{ ... }: {
  imports = [ ./hardware-configuration.nix ];

  networking.networkmanager.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
