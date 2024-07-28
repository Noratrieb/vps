# https://github.com/nix-community/dns.nix
{ pkgs, lib, ... }:
let
  data = with pkgs.nix-dns.lib.combinators;
    let
      hour1 = 3600;
      normalHost = ipv4: ipv6:
        lib.optionalAttrs (ipv4 != null) { A = [ (ttl hour1 (a ipv4)) ]; } //
        lib.optionalAttrs (ipv6 != null) { AAAA = [ (ttl hour1 (aaaa ipv6)) ]; };
      dns1 = normalHost "154.38.163.74" null;
      dns2 = normalHost "128.140.3.7" "2a01:4f8:c2c:d616::";

      vps1 = normalHost "161.97.165.1" null;
      vps3 = normalHost "134.255.181.139" null;
    in
    # vps1 contains root noratrieb.dev
    vps1 // {
      SOA = {
        nameServer = "ns1.noratrieb.dev";
        adminEmail = "void@noratrieb.dev";
        serial = 2024072601;
      };

      NS = [
        "ns1.noratrieb.dev"
        "ns2.noratrieb.dev"
      ];

      subdomains = {
        www.CNAME = [ (cname "noratrieb.dev") ];
        pronouns.TXT = [
          "she/her"
        ];

        test1.A = vps1.A ++ vps3.A;

        localhost.A = [ (a "127.0.0.1") ];
        newtest.TXT = [ "uwu it works" ];

        # TODO: generate dynamically from IPs...
        infra.subdomains = {
          inherit dns1;
          inherit dns2;
          inherit vps1;
          inherit vps3;
        };
      };
    };
in
pkgs.writeTextFile {
  name = "noratrieb.dev.zone";
  text = pkgs.nix-dns.lib.toString "noratrieb.dev" data;
}
