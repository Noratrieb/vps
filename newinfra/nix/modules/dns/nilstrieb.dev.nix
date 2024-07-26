# https://github.com/nix-community/dns.nix
{ pkgs, ... }:
let
  data = with pkgs.nix-dns.lib.combinators;
    let
      dns1 = host "154.38.163.74" null;
      dns2 = host "128.140.3.7" "2a01:4f8:c2c:d616::";

      vps1 = host "161.97.165.1" null;
      vps2 = host "184.174.32.252" null;
    in
    {
      SOA = {
        nameServer = "ns1.noratrieb.dev";
        adminEmail = "void@noratrieb.dev";
        serial = 2024072601;
      };

      TXT = [
        "protonmail-verification=86964dcc4994261eab23dbc53dad613b10bab6de"
        "v=spf1 include:_spf.protonmail.ch ~all"
      ];

      NS = [
        "ns1.noratrieb.dev"
        "ns2.noratrieb.dev"
      ];

      A = [
        # GH Pages
        (a "185.199.108.153")
        (a "185.199.109.153")
        (a "185.199.110.153")
        (a "185.199.111.153")
      ];
      AAAA = [
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
        blog.CNAME = [ (cname "nilstrieb.github.io") ];

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

        ns1 = dns1;
        ns2 = dns2;

        newtest.TXT = [ "uwu it works" ];
        bsky.subdomains.atproto.TXT = [ "did=did:plc:pqyzoyxk7gfcbxk65mjyncyl" ];
      };
    };
in
pkgs.writeTextFile {
  name = "noratrieb.dev.zone";
  text = pkgs.nix-dns.lib.toString "noratrieb.dev" data;
}
