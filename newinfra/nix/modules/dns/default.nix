{ pkgs, ... }: {
  # get the package for the debugging tools
  environment.systemPackages = with pkgs; [ knot-dns ];

  networking.firewall.allowedUDPPortRanges = [
    { from = 53; to = 53; }
  ];

  services.knot = {
    enable = true;
    settingsFile = pkgs.writeTextFile {
      name = "knot.conf";
      text = ''
        server:
            listen: 0.0.0.0@53
            listen: ::@53

        zone:
          - domain: noratrieb.dev
            storage: /var/lib/knot/zones/
            file: ${import ./noratrieb.dev.nix { inherit pkgs; }}
        log:
          - target: syslog
            any: info
      '';
    };
  };
}
