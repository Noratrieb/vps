{ ... }: {
  # TODO: put the actual setup here.
  networking.hosts = {
    "10.0.0.1" = [ "vps1.local" ];
    "10.0.0.3" = [ "vps3.local" ];
  };
}
