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
    {
      SOA = {
        nameServer = "154.38.163.74"; #"ns1.noratrieb.dev";
        adminEmail = "void@noratrieb.dev";
        serial = 2024072601;
      };

      NS = [
        "154.38.163.74" #"ns1.noratrieb.dev"
        #"ns2.noratrieb.dev"
      ];

      A = [ (a "161.97.165.1") ];
      AAAA = [ ];

      subdomains = {
        www.CNAME = [ (cname "noratrieb.dev") ];
        pronouns.TXT = [
          "she/her"
        ];

        ns1 = host "154.38.163.74" null;

        infra.subdomains = {
          dns1 = host "154.38.163.74" null;
        };
      };
    };
in
pkgs.writeTextFile {
  name = "noratrieb.dev.zone";
  text = dns.lib.toString "noratrieb.dev" data;
}
