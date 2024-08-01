# https://github.com/nix-community/dns.nix
{ pkgs, lib, networkingConfig, ... }:
let
  data = with pkgs.nix-dns.lib.combinators;
    let
      hour1 = 3600;
      hostsToDns = builtins.mapAttrs
        (name: { publicIPv4, publicIPv6, ... }:
          lib.optionalAttrs (publicIPv4 != null) { A = [ (ttl hour1 (a publicIPv4)) ]; } //
          lib.optionalAttrs (publicIPv6 != null) { AAAA = [ (ttl hour1 (aaaa publicIPv6)) ]; })
        networkingConfig;
      vps2 = {
        A = [ "184.174.32.252" ];
      };
    in
    with hostsToDns;
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
        ns1 = dns1;
        ns2 = dns2;

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
