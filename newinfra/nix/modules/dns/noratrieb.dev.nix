# https://github.com/nix-community/dns.nix
{ pkgs, ... }:
let
  # TODO: do this in a central place
  dns = import (pkgs.fetchFromGitHub {
    owner = "nix-community";
    repo = "dns.nix";
    rev = "v1.1.2";
    hash = "sha256-EHiDP2jEa7Ai5ZwIf5uld9RVFcV77+2SUxjQXwJsJa0=";
  });

  data = with dns.lib.combinators;
    let
      dns1 = host "154.38.163.74" null;
      dns2 = host "128.140.3.7" "2a01:4f8:c2c:d616::";
    in
    {
      SOA = {
        nameServer = "ns1.noratrieb.dev";
        adminEmail = "void@noratrieb.dev";
        serial = 2024072601;
      };

      NS = [
        "ns1.noratrieb.dev"
        "ns2.noratrieb.dev"
      ];

      A = [ (a "161.97.165.1") ];
      AAAA = [ ];

      subdomains = {
        www.CNAME = [ (cname "noratrieb.dev") ];
        pronouns.TXT = [
          "she/her"
        ];

        # ns1 = dns1;
        # ns2 = dns2;

        infra.subdomains = {
          inherit dns1;
          inherit dns2;
        };
      };
    };
in
pkgs.writeTextFile {
  name = "noratrieb.dev.zone";
  text = dns.lib.toString "noratrieb.dev" data;
}
