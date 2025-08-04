{ lib, pkgs, my-projects-versions, ... }:
let
  cluelessh = import (pkgs.fetchFromGitHub my-projects-versions.cluelessh.fetchFromGitHub);
in
{
  systemd.services.fakessh = {
    description = "cluelessh-faked ssh honeypot";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "5s";
      ExecStart = "${lib.getExe' (cluelessh {inherit pkgs;}) "cluelessh-faked" }";

      # i really don't trust this.
      DynamicUser = true;
      AmbientCapabilities = "CAP_NET_BIND_SERVICE";
      MemoryHigh = "100M";
      MemoryMax = "200M";

      # config
      Environment = [
        "FAKESSH_LISTEN_ADDR=0.0.0.0:22"
        "RUST_LOG=debug"
        #"FAKESSH_JSON_LOGS=1"
      ];
    };
  };
  networking.firewall.allowedTCPPorts = [ 22 ];
}
