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
      vps2 = normalHost "184.174.32.252" null;
    in
    {
      SOA = {
        nameServer = "ns1.nilstrieb.dev";
        adminEmail = "void@noratrieb.dev";
        serial = 2024072601;
      };

      TXT = [
        "protonmail-verification=86964dcc4994261eab23dbc53dad613b10bab6de"
        "v=spf1 include:_spf.protonmail.ch ~all"
      ];

      NS = [
        "ns1.nilstrieb.dev"
        "ns2.nilstrieb.dev"
      ];

      A = map (ttl hour1) [
        # GH Pages
        (a "185.199.108.153")
        (a "185.199.109.153")
        (a "185.199.110.153")
        (a "185.199.111.153")
      ];
      AAAA = map (ttl hour1) [
        # GH Pages
        (aaaa "2606:50c0:8002:0:0:0:0:153")
        (aaaa "2606:50c0:8003:0:0:0:0:153")
        (aaaa "2606:50c0:8000:0:0:0:0:153")
        (aaaa "2606:50c0:8001:0:0:0:0:153")
      ];

      MX = with mx; [
        (mx 10 "mail.protonmail.ch")
        (mx 20 "mailsec.protonmail.ch")
      ];

      subdomains = {
        www = vps2;
        blog.CNAME = map (ttl hour1) [ (cname "nilstrieb.github.io") ];

        # apps
        bisect-rustc = vps2;
        cors-school = vps2 // {
          subdomains.api = vps2;
        };
        docker = vps2;
        hugo-chat = vps2 // {
          subdomains.api = vps2;
        };
        olat = vps2;
        uptime = vps2;

        localhost.A = [ (a "127.0.0.1") ];

        # infra (legacy)
        inherit vps1;
        inherit vps2;
        inherit dns1;
        inherit dns2;

        pronouns.TXT = [
          "TODO"
        ];

        newtest.TXT = [ "uwu it works" ];
        bsky.subdomains.atproto.TXT = [ "did=did:plc:pqyzoyxk7gfcbxk65mjyncyl" ];
      };
    };
in
pkgs.writeTextFile {
  name = "nilstrieb.dev.zone";
  text = pkgs.nix-dns.lib.toString "nilstrieb.dev" data;
}
