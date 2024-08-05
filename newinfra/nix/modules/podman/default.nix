{ ... }: {
  virtualisation.podman = {
    enable = true;
  };
  # https://github.com/NixOS/nixpkgs/issues/226365
  networking.firewall.interfaces."podman+".allowedUDPPorts = [ 53 5353 ];
  age.secrets.docker_registry_password.file = ../../secrets/docker_registry_password.age;
}
