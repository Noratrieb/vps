# https://github.com/nix-community/dns.nix
{ pkgs, ... }:
let
  data = with pkgs.nix-dns.lib.combinators;
    let
      dns1 = host "154.38.163.74" null;
      dns2 = host "128.140.3.7" "2a01:4f8:c2c:d616::";

      vps1 = host "161.97.165.1" null;

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

      A = [ (a "184.174.32.252") ];
      AAAA = [ ];

      subdomains = {
        www.CNAME = [ (cname "noratrieb.dev") ];
        pronouns.TXT = [
          "she/her"
        ];

        localhost.A = [ (a "127.0.0.1") ];
        newtest.TXT = [ "uwu it works" ];

        infra.subdomains = {
          inherit dns1;
          inherit dns2;
          inherit vps1;
        };
      };
    };
in
pkgs.writeTextFile {
  name = "noratrieb.dev.zone";
  text = pkgs.nix-dns.lib.toString "noratrieb.dev" data;
}
