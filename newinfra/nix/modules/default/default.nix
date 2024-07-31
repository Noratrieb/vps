{ pkgs, config, name, ... }: {
  deployment.targetHost = "${config.networking.hostName}.infra.noratrieb.dev";

  imports = [
    "${builtins.fetchTarball "https://github.com/ryantm/agenix/archive/de96bd907d5fbc3b14fc33ad37d1b9a3cb15edc6.tar.gz"}/modules/age.nix" # main 2024-07-26
  ];

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    traceroute
    dnsutils
  ];

  networking.hostName = name;

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
}
